import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_api.dart';
import '../../support/fixtures.dart';
import 'coach_test_support.dart';

const _path = '/coach/clients/c1/relationship';

Map<String, dynamic> _row(String status) => clientItemJson(
  id: 'c1',
  name: 'Andrei Popescu',
  email: 'andrei@example.ro',
  status: status,
);

Map<String, dynamic> _relationshipJson(String status) => {
  'clientId': 'c1',
  'firstName': 'Andrei',
  'lastName': 'Popescu',
  'email': 'andrei@example.ro',
  'status': status,
  'startedAt': '2026-09-01T10:00:00Z',
};

/// Serves one row whose status follows the last successful PATCH.
Future<FakeApi> _pump(WidgetTester t, String status) async {
  var current = status;
  final api = await pumpCoach(
    t,
    clients: (_) =>
        FakeResponse.json(200, clientPageJson(items: [_row(current)])),
  );
  api.on('PATCH', _path, (r) {
    current = (r.data as Map)['status'] as String;
    return FakeResponse.json(200, _relationshipJson(current));
  });
  return api;
}

Future<void> _openMenu(WidgetTester t, String item) async {
  await t.tap(find.byTooltip('Client actions'));
  await t.pumpAndSettle();
  await t.tap(find.text(item));
  await t.pumpAndSettle();
}

List<Object?> _patches(FakeApi api) => [
  for (final r in api.requests)
    if (r.method == 'PATCH') r.data,
];

void main() {
  group('menu', () {
    testWidgets('an active client can be paused or ended', (t) async {
      await _pump(t, 'ACTIVE');
      await t.tap(find.byTooltip('Client actions'));
      await t.pumpAndSettle();
      expect(find.text('Pause'), findsOneWidget);
      expect(find.text('End relationship'), findsOneWidget);
      expect(find.text('Resume'), findsNothing);
    });

    testWidgets('a paused client can be resumed or ended', (t) async {
      await _pump(t, 'PAUSED');
      await t.tap(find.byTooltip('Client actions'));
      await t.pumpAndSettle();
      expect(find.text('Resume'), findsOneWidget);
      expect(find.text('End relationship'), findsOneWidget);
      expect(find.text('Pause'), findsNothing);
    });

    testWidgets('an ended relationship has no actions', (t) async {
      await _pump(t, 'ENDED');
      expect(find.text('Andrei Popescu'), findsOneWidget);
      expect(find.byTooltip('Client actions'), findsNothing);
      expect(find.byTooltip('Invitation actions'), findsNothing);
    });

    testWidgets('an unverified coach can still pause', (t) async {
      final api = await pumpCoach(
        t,
        status: 'PENDING',
        clients: (_) =>
            FakeResponse.json(200, clientPageJson(items: [_row('ACTIVE')])),
      );
      api.on(
        'PATCH',
        _path,
        (_) => FakeResponse.json(200, _relationshipJson('PAUSED')),
      );
      await _openMenu(t, 'Pause');
      expect(_patches(api), [
        {'status': 'PAUSED'},
      ]);
    });
  });

  group('pause and resume', () {
    testWidgets('pause runs without confirmation and reloads', (t) async {
      final api = await _pump(t, 'ACTIVE');
      final loadsBefore = api.count('GET', '/coach/clients');
      await _openMenu(t, 'Pause');
      expect(find.byType(AlertDialog), findsNothing);
      expect(_patches(api), [
        {'status': 'PAUSED'},
      ]);
      expect(
        find.text('Relationship with Andrei Popescu paused.'),
        findsOneWidget,
      );
      expect(api.count('GET', '/coach/clients'), loadsBefore + 1);
      expect(find.text('Paused'), findsOneWidget);
    });

    testWidgets('resume runs without confirmation and reloads', (t) async {
      final api = await _pump(t, 'PAUSED');
      await _openMenu(t, 'Resume');
      expect(find.byType(AlertDialog), findsNothing);
      expect(_patches(api), [
        {'status': 'ACTIVE'},
      ]);
      expect(
        find.text('Relationship with Andrei Popescu resumed.'),
        findsOneWidget,
      );
      expect(find.text('Active'), findsOneWidget);
    });
  });

  group('end', () {
    testWidgets('asks for confirmation, then ends', (t) async {
      final api = await _pump(t, 'PAUSED');
      await _openMenu(t, 'End relationship');
      expect(
        find.text('End the relationship with Andrei Popescu?'),
        findsOneWidget,
      );
      expect(
        find.text(
          "This can't be undone. You'll lose access to this client's data, "
          'and they will be able to join another coach.',
        ),
        findsOneWidget,
      );
      expect(_patches(api), isEmpty);

      await t.tap(find.widgetWithText(FilledButton, 'End relationship'));
      await t.pumpAndSettle();
      expect(_patches(api), [
        {'status': 'ENDED'},
      ]);
      expect(
        find.text('Relationship with Andrei Popescu ended.'),
        findsOneWidget,
      );
    });

    testWidgets('Keep client sends nothing', (t) async {
      final api = await _pump(t, 'ACTIVE');
      await _openMenu(t, 'End relationship');
      await t.tap(find.widgetWithText(TextButton, 'Keep client'));
      await t.pumpAndSettle();
      expect(_patches(api), isEmpty);
      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  group('errors', () {
    for (final (code, status, message) in [
      (
        'INVALID_RELATIONSHIP_TRANSITION',
        409,
        "This client's status changed in the meantime. The list is up to date now.",
      ),
      ('CLIENT_NOT_FOUND', 404, 'This client is no longer linked to you.'),
    ]) {
      testWidgets('$code shows a message and reloads', (t) async {
        final api = await pumpCoach(
          t,
          clients: (_) =>
              FakeResponse.json(200, clientPageJson(items: [_row('ACTIVE')])),
        );
        api.on('PATCH', _path, (_) => FakeResponse.problem(status, code));
        final loadsBefore = api.count('GET', '/coach/clients');
        await _openMenu(t, 'Pause');
        expect(find.text(message), findsOneWidget);
        expect(api.count('GET', '/coach/clients'), loadsBefore + 1);
      });
    }
  });
}
