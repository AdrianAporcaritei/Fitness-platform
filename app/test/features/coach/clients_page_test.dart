import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_api.dart';
import '../../support/fixtures.dart';
import '../../support/test_app.dart';
import 'coach_test_support.dart';

final _rows = [
  clientItemJson(
    id: 'c1',
    name: 'Andrei Popescu',
    email: 'andrei@example.ro',
    status: 'ACTIVE',
    invitedAt: '2026-09-01T10:00:00Z',
  ),
  clientItemJson(
    id: 'i1',
    name: 'Irina Voicu',
    email: 'irina@example.ro',
    status: 'INVITED',
    invitedAt: '2026-10-10T10:00:00Z',
    invitationExpiresAt: '2026-10-17T10:00:00Z',
  ),
  clientItemJson(
    id: 'i2',
    name: 'Larisa Neagu',
    email: 'larisa@example.ro',
    status: 'INVITED',
    invitedAt: '2026-10-01T10:00:00Z',
    invitationExpiresAt: '2026-10-08T10:00:00Z',
    invitationExpired: true,
  ),
  clientItemJson(
    id: 'c2',
    name: 'Radu Georgescu',
    email: 'radu@example.ro',
    status: 'PAUSED',
  ),
];

FakeHandler _page(List<Map<String, dynamic>> items, {int? total}) =>
    (r) => FakeResponse.json(
      200,
      clientPageJson(
        items: items,
        page: r.queryParameters['page'] as int,
        totalItems: total,
      ),
    );

void main() {
  group('states', () {
    testWidgets('loading shows a spinner, then the rows', (t) async {
      Completer<FakeResponse>? gate;
      await pumpCoach(
        t,
        clients: (r) =>
            gate?.future ??
            FakeResponse.json(200, clientPageJson(items: _rows)),
      );
      gate = Completer();
      await t.tap(find.text('All statuses'));
      await t.pumpAndSettle();
      await t.tap(find.text('Paused').last);
      await t.pump();
      await t.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Andrei Popescu'), findsNothing);

      gate.complete(FakeResponse.json(200, clientPageJson(items: _rows)));
      await t.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Andrei Popescu'), findsOneWidget);
    });

    testWidgets('error shows the message and Retry reloads', (t) async {
      var calls = 0;
      final api = await pumpCoach(
        t,
        clients: (_) => ++calls == 1
            ? FakeResponse.networkError()
            : FakeResponse.json(200, clientPageJson(items: _rows)),
      );
      expect(find.text("Couldn't load your clients."), findsOneWidget);
      expect(
        find.text("Can't reach the server. Check your connection."),
        findsOneWidget,
      );

      await t.tap(find.widgetWithText(OutlinedButton, 'Retry'));
      await t.pumpAndSettle();
      expect(find.text('Andrei Popescu'), findsOneWidget);
      expect(api.count('GET', '/coach/clients'), 2);
    });

    testWidgets('no clients: empty state invites the first client', (t) async {
      await pumpCoach(t);
      expect(find.text('No clients yet'), findsOneWidget);
      await t.tap(
        find.widgetWithText(FilledButton, 'Invite your first client'),
      );
      await t.pumpAndSettle();
      expect(find.text('Add client'), findsOneWidget);
    });

    testWidgets('no match: clear filters resets the URL', (t) async {
      final api = await pumpCoach(
        t,
        location: '/coach/clients?q=zzz&status=paused',
        clients: (r) => FakeResponse.json(
          200,
          clientPageJson(
            items: r.queryParameters.containsKey('q') ? [] : _rows,
          ),
        ),
      );
      expect(find.text('No clients match these filters'), findsOneWidget);
      expect(find.text('No clients yet'), findsNothing);

      await t.tap(find.widgetWithText(OutlinedButton, 'Clear filters'));
      await t.pumpAndSettle();
      expect(currentLocation(t), '/coach/clients');
      expect(lastListQuery(api), {'page': 0, 'size': 20});
      expect(find.text('Andrei Popescu'), findsOneWidget);
      final search = t.widget<TextField>(find.byType(TextField));
      expect(search.controller!.text, isEmpty);
    });
  });

  group('table', () {
    testWidgets('shows name, email, status and invitation dates', (t) async {
      await pumpCoach(t, clients: _page(_rows));
      expect(find.text('Clients'), findsWidgets);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('Andrei Popescu'), findsOneWidget);
      expect(find.text('andrei@example.ro'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Paused'), findsOneWidget);
      expect(find.text('Invited'), findsNWidgets(2));
      expect(find.text('Sep 1, 2026'), findsOneWidget);
      expect(find.text('Expires Oct 17, 2026'), findsOneWidget);
      expect(find.text('Invitation expired'), findsOneWidget);
      expect(find.text('1–4 of 4'), findsOneWidget);
      expect(find.byTooltip('Invitation actions'), findsNWidgets(2));
      expect(find.byTooltip('Client actions'), findsNWidgets(2));
    });

    testWidgets('a row without name or email shows placeholders', (t) async {
      await pumpCoach(
        t,
        clients: _page([
          clientItemJson(name: null, email: null, status: 'INVITED'),
        ]),
      );
      expect(find.text('(no name)'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('narrow screen shows cards', (t) async {
      await pumpCoach(t, clients: _page(_rows), size: const Size(400, 900));
      expect(find.text('NAME'), findsNothing);
      expect(find.text('Andrei Popescu'), findsOneWidget);
      expect(find.text('Invited on: Sep 1, 2026'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  group('query', () {
    testWidgets('URL parameters drive the request', (t) async {
      final api = await pumpCoach(
        t,
        location: '/coach/clients?q=ana&status=invited&page=3',
        clients: _page([], total: 45),
      );
      expect(lastListQuery(api), {
        'page': 2,
        'size': 20,
        'q': 'ana',
        'status': 'INVITED',
      });
      final search = t.widget<TextField>(find.byType(TextField));
      expect(search.controller!.text, 'ana');
    });

    testWidgets('search is debounced and resets the page', (t) async {
      final api = await pumpCoach(
        t,
        location: '/coach/clients?page=2',
        clients: _page(_rows, total: 30),
      );
      final before = api.count('GET', '/coach/clients');
      await t.enterText(find.byType(TextField), 'ir');
      await t.pump(const Duration(milliseconds: 100));
      await t.enterText(find.byType(TextField), 'iri');
      await t.pump(const Duration(milliseconds: 200));
      expect(api.count('GET', '/coach/clients'), before);

      await t.pump(const Duration(milliseconds: 150));
      await t.pumpAndSettle();
      expect(currentLocation(t), '/coach/clients?q=iri');
      expect(lastListQuery(api), {'page': 0, 'size': 20, 'q': 'iri'});
      expect(api.count('GET', '/coach/clients'), before + 1);
    });

    testWidgets('status filter goes into the URL', (t) async {
      final api = await pumpCoach(t, clients: _page(_rows));
      await t.tap(find.text('All statuses'));
      await t.pumpAndSettle();
      await t.tap(find.text('Ended').last);
      await t.pumpAndSettle();
      expect(currentLocation(t), '/coach/clients?status=ended');
      expect(lastListQuery(api)['status'], 'ENDED');
    });

    testWidgets('next and previous page', (t) async {
      final api = await pumpCoach(t, clients: _page(_rows, total: 44));
      expect(find.text('1–4 of 44'), findsOneWidget);
      final previous = find.widgetWithIcon(IconButton, Icons.chevron_left);
      expect(t.widget<IconButton>(previous).onPressed, isNull);

      await t.tap(find.widgetWithIcon(IconButton, Icons.chevron_right));
      await t.pumpAndSettle();
      expect(currentLocation(t), '/coach/clients?page=2');
      expect(lastListQuery(api)['page'], 1);
      expect(find.text('21–24 of 44'), findsOneWidget);

      await t.tap(previous);
      await t.pumpAndSettle();
      expect(currentLocation(t), '/coach/clients');
    });

    testWidgets('a page past the end moves to the last page', (t) async {
      await pumpCoach(
        t,
        location: '/coach/clients?page=4',
        clients: (r) => FakeResponse.json(
          200,
          clientPageJson(
            items: r.queryParameters['page'] == 1 ? _rows : [],
            page: r.queryParameters['page'] as int,
            totalItems: 24,
          ),
        ),
      );
      expect(currentLocation(t), '/coach/clients?page=2');
      expect(find.text('Andrei Popescu'), findsOneWidget);
    });

    testWidgets('a page of an emptied list moves to the first page', (t) async {
      await pumpCoach(t, location: '/coach/clients?page=3', clients: _page([]));
      expect(currentLocation(t), '/coach/clients');
      expect(find.text('No clients yet'), findsOneWidget);
    });
  });

  testWidgets('unverified coach cannot add or regenerate', (t) async {
    await pumpCoach(t, status: 'PENDING', clients: _page(_rows));
    final add = find.widgetWithText(FilledButton, '+ Add client');
    expect(t.widget<FilledButton>(add).onPressed, isNull);
    expect(
      find.byTooltip('Confirm your email to add clients.'),
      findsOneWidget,
    );

    await t.tap(find.byTooltip('Invitation actions').first);
    await t.pumpAndSettle();
    final regenerate = find.ancestor(
      of: find.text('Regenerate link'),
      matching: find.byType(PopupMenuItem<void>),
    );
    expect(t.widget<PopupMenuItem<void>>(regenerate).enabled, isFalse);
  });
}
