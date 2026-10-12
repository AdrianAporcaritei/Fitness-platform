import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_api.dart';
import '../../support/fixtures.dart';
import 'coach_test_support.dart';

const _link = 'http://localhost:5173/join/ABCDE-FGHJK';

Map<String, dynamic> _linkJson({
  String id = 'i1',
  String link = _link,
  String name = 'Maria Pavel',
}) => {
  'invitationId': id,
  'name': name,
  'email': 'maria@example.ro',
  'code': link.split('/').last,
  'link': link,
  'expiresAt': '2026-10-18T12:00:00Z',
};

final _invited = clientItemJson(
  id: 'i1',
  name: 'Irina Voicu',
  email: 'irina@example.ro',
  status: 'INVITED',
  invitationExpiresAt: '2026-10-17T10:00:00Z',
);

/// Records clipboard writes.
List<String> _mockClipboard(WidgetTester t) {
  final copied = <String>[];
  t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'Clipboard.setData') {
        copied.add((call.arguments as Map)['text'] as String);
      }
      return null;
    },
  );
  addTearDown(
    () => t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return copied;
}

Future<void> _openAdd(WidgetTester t) async {
  await t.tap(find.widgetWithText(FilledButton, '+ Add client'));
  await t.pumpAndSettle();
}

Future<void> _fillAndSubmit(
  WidgetTester t, {
  String name = ' Maria Pavel ',
  String email = ' maria@example.ro ',
}) async {
  final dialog = find.byType(Dialog);
  await t.enterText(
    find.descendant(of: dialog, matching: find.byType(TextFormField)).at(0),
    name,
  );
  await t.enterText(
    find.descendant(of: dialog, matching: find.byType(TextFormField)).at(1),
    email,
  );
  await t.tap(find.widgetWithText(FilledButton, 'Create invitation'));
  await t.pumpAndSettle();
}

Future<void> _openMenu(WidgetTester t, String item) async {
  await t.tap(find.byTooltip('Invitation actions'));
  await t.pumpAndSettle();
  await t.tap(find.text(item));
  await t.pumpAndSettle();
}

void main() {
  group('add client', () {
    testWidgets('shows the link once, copies it, then reloads the list', (
      t,
    ) async {
      final copied = _mockClipboard(t);
      final api = await pumpCoach(t);
      api.on(
        'POST',
        '/coach/clients',
        (_) => FakeResponse.json(201, _linkJson()),
      );
      await _openAdd(t);
      await _fillAndSubmit(t);

      final add = api.requests.lastWhere((r) => r.method == 'POST');
      expect(add.data, {'name': 'Maria Pavel', 'email': 'maria@example.ro'});
      expect(find.text('Invitation link for Maria Pavel'), findsOneWidget);
      expect(find.text(_link), findsOneWidget);

      await t.tap(find.widgetWithText(FilledButton, 'Copy link'));
      await t.pump();
      expect(copied, [_link]);
      expect(find.text('Copied'), findsOneWidget);
      await t.pump(const Duration(seconds: 2));
      expect(find.text('Copy link'), findsOneWidget);

      final loadsBefore = api.count('GET', '/coach/clients');
      await t.tap(find.widgetWithText(OutlinedButton, 'Done'));
      await t.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(find.text(_link), findsNothing);
      expect(api.count('GET', '/coach/clients'), loadsBefore + 1);

      // Reopening starts a new, empty form: the link cannot be seen again.
      await _openAdd(t);
      expect(find.text(_link), findsNothing);
      expect(find.text('Create invitation'), findsOneWidget);
    });

    testWidgets('validates on the client without a request', (t) async {
      final api = await pumpCoach(t);
      await _openAdd(t);
      await _fillAndSubmit(t, name: ' ', email: 'not-an-email');
      expect(find.text('Required'), findsOneWidget);
      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(api.count('POST', '/coach/clients'), 0);
    });

    testWidgets('a conflict shows in the banner and keeps the form', (t) async {
      final api = await pumpCoach(t);
      api.on(
        'POST',
        '/coach/clients',
        (_) => FakeResponse.problem(409, 'INVITE_ALREADY_PENDING'),
      );
      await _openAdd(t);
      await _fillAndSubmit(t);
      expect(
        find.text('You already have a pending invitation for this email.'),
        findsOneWidget,
      );
      expect(find.text('Create invitation'), findsOneWidget);
    });

    testWidgets('server field errors go under the fields', (t) async {
      final api = await pumpCoach(t);
      api.on(
        'POST',
        '/coach/clients',
        (_) => FakeResponse.problem(
          400,
          'VALIDATION_FAILED',
          errors: [
            {'field': 'email', 'code': 'INVALID_EMAIL'},
          ],
        ),
      );
      await _openAdd(t);
      await _fillAndSubmit(t);
      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('Cancel closes without a request', (t) async {
      final api = await pumpCoach(t);
      await _openAdd(t);
      await t.tap(find.widgetWithText(TextButton, 'Cancel'));
      await t.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(api.count('POST', '/coach/clients'), 0);
    });
  });

  group('regenerate', () {
    testWidgets('after confirmation shows the new link once', (t) async {
      final api = await pumpCoach(
        t,
        clients: (_) =>
            FakeResponse.json(200, clientPageJson(items: [_invited])),
      );
      const renewed = 'http://localhost:5173/join/ZZZZZ-YYYYY';
      api.on(
        'POST',
        '/coach/invites/i1/regenerate',
        (_) => FakeResponse.json(
          200,
          _linkJson(link: renewed, name: 'Irina Voicu'),
        ),
      );
      await _openMenu(t, 'Regenerate link');
      expect(find.text('Regenerate the link?'), findsOneWidget);
      expect(find.textContaining('Irina Voicu'), findsWidgets);

      await t.tap(find.widgetWithText(FilledButton, 'Regenerate'));
      await t.pumpAndSettle();
      expect(api.count('POST', '/coach/invites/i1/regenerate'), 1);
      expect(find.text(renewed), findsOneWidget);

      final loadsBefore = api.count('GET', '/coach/clients');
      await t.tap(find.widgetWithText(OutlinedButton, 'Done'));
      await t.pumpAndSettle();
      expect(find.text(renewed), findsNothing);
      expect(api.count('GET', '/coach/clients'), loadsBefore + 1);
    });

    testWidgets('declining the confirmation sends nothing', (t) async {
      final api = await pumpCoach(
        t,
        clients: (_) =>
            FakeResponse.json(200, clientPageJson(items: [_invited])),
      );
      await _openMenu(t, 'Regenerate link');
      await t.tap(find.widgetWithText(TextButton, 'Cancel'));
      await t.pumpAndSettle();
      expect(api.count('POST', '/coach/invites/i1/regenerate'), 0);
    });

    testWidgets('a failure shows a message and reloads', (t) async {
      final api = await pumpCoach(
        t,
        clients: (_) =>
            FakeResponse.json(200, clientPageJson(items: [_invited])),
      );
      api.on(
        'POST',
        '/coach/invites/i1/regenerate',
        (_) => FakeResponse.problem(409, 'INVITE_NOT_PENDING'),
      );
      final loadsBefore = api.count('GET', '/coach/clients');
      await _openMenu(t, 'Regenerate link');
      await t.tap(find.widgetWithText(FilledButton, 'Regenerate'));
      await t.pumpAndSettle();
      expect(
        find.text('This invitation is no longer pending.'),
        findsOneWidget,
      );
      expect(find.byType(Dialog), findsNothing);
      expect(api.count('GET', '/coach/clients'), loadsBefore + 1);
    });
  });

  group('cancel invitation', () {
    testWidgets('after confirmation cancels and reloads', (t) async {
      var cancelled = false;
      final api = await pumpCoach(
        t,
        clients: (_) => FakeResponse.json(
          200,
          clientPageJson(items: cancelled ? [] : [_invited]),
        ),
      );
      api.on('DELETE', '/coach/invites/i1', (_) {
        cancelled = true;
        return FakeResponse.empty(204);
      });
      await _openMenu(t, 'Cancel invitation');
      expect(find.text('Cancel the invitation?'), findsOneWidget);
      expect(
        find.text("Irina Voicu won't be able to join with this link anymore."),
        findsOneWidget,
      );

      await t.tap(find.widgetWithText(FilledButton, 'Cancel invitation'));
      await t.pumpAndSettle();
      expect(api.count('DELETE', '/coach/invites/i1'), 1);
      expect(find.text('Invitation cancelled.'), findsOneWidget);
      expect(find.text('Irina Voicu'), findsNothing);
      expect(find.text('No clients yet'), findsOneWidget);
    });

    testWidgets('Keep it sends nothing', (t) async {
      final api = await pumpCoach(
        t,
        clients: (_) =>
            FakeResponse.json(200, clientPageJson(items: [_invited])),
      );
      await _openMenu(t, 'Cancel invitation');
      await t.tap(find.widgetWithText(TextButton, 'Keep it'));
      await t.pumpAndSettle();
      expect(api.count('DELETE', '/coach/invites/i1'), 0);
      expect(find.text('Irina Voicu'), findsOneWidget);
    });
  });
}
