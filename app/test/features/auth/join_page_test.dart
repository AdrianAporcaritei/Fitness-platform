import 'package:ana_fit_lab/core/auth/token_store.dart';
import 'package:ana_fit_lab/core/locale/browser_time_zone.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_container.dart';
import '../../support/fake_api.dart';
import '../../support/fixtures.dart';
import '../../support/test_app.dart';

const _preview = {
  'coachFirstName': 'Maria',
  'coachLastName': 'Ionescu',
  'valid': true,
};

FakeApi _apiWithPreview({String code = 'abc'}) {
  final api = FakeApi();
  api.on('GET', '/invites/$code', (_) => FakeResponse.json(200, _preview));
  return api;
}

void _signupOk(FakeApi api) => api.on(
  'POST',
  '/auth/register/client',
  (_) => FakeResponse.json(
    201,
    tokenJson(
      now: testNow,
      user: userJson(role: 'CLIENT', status: 'PENDING'),
    ),
  ),
);

Future<void> _fillAndSubmit(WidgetTester t) async {
  await t.enterText(find.byType(TextFormField).at(0), 'Ion');
  await t.enterText(find.byType(TextFormField).at(1), 'Vasile');
  await t.enterText(find.byType(TextFormField).at(2), 'ion@example.ro');
  await t.enterText(find.byType(TextFormField).at(3), 'secret-password');
  await t.tap(find.widgetWithText(FilledButton, 'Create account and join'));
  await t.pumpAndSettle();
}

Future<FakeApi> _pumpSignedIn(WidgetTester t, FakeApi api, String loc) async {
  final store = MemoryTokenStore();
  await store.write('r1', testNow.add(const Duration(days: 10)));
  api.on(
    'POST',
    '/auth/refresh',
    (_) => FakeResponse.json(200, tokenJson(now: testNow)),
  );
  await pumpApp(t, api: api, store: store, initialLocation: loc);
  return api;
}

void main() {
  testWidgets('shows the coach name and the form', (t) async {
    await pumpApp(t, api: _apiWithPreview(), initialLocation: '/join/abc');
    expect(
      find.text("You're joining Maria Ionescu's coaching"),
      findsOneWidget,
    );
    expect(find.byType(TextFormField), findsNWidgets(4));
  });

  testWidgets('join passes the raw code to the API', (t) async {
    final api = _apiWithPreview(code: 'abcde-fghij');
    _signupOk(api);
    await pumpApp(t, api: api, initialLocation: '/join/abcde-fghij');
    expect(
      api.requests.first.uri.path.endsWith('/invites/abcde-fghij'),
      isTrue,
    );
    await _fillAndSubmit(t);
    final body = api.requests.last.data as Map;
    expect(body['code'], 'abcde-fghij');
  });

  final problems = {
    'INVITE_EXPIRED': (410, 'This invite has expired'),
    'INVITE_USED': (410, 'This invite was already used'),
    'INVITE_REVOKED': (410, 'This invite is no longer valid'),
    'INVITE_NOT_FOUND': (404, "We couldn't find this invite"),
    'COACH_UNAVAILABLE': (409, "Your coach isn't available right now"),
  };
  for (final e in problems.entries) {
    testWidgets('preview ${e.key} shows its link problem', (t) async {
      final api = FakeApi();
      api.on(
        'GET',
        '/invites/abc',
        (_) => FakeResponse.problem(e.value.$1, e.key),
      );
      await pumpApp(t, api: api, initialLocation: '/join/abc');
      expect(find.text(e.value.$2), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);
      expect(
        find.text('Go to login'),
        e.key == 'INVITE_USED' ? findsOneWidget : findsNothing,
      );
    });
  }

  testWidgets('INVITE_USED action goes to login', (t) async {
    final api = FakeApi();
    api.on(
      'GET',
      '/invites/abc',
      (_) => FakeResponse.problem(410, 'INVITE_USED'),
    );
    await pumpApp(t, api: api, initialLocation: '/join/abc');
    await t.tap(find.text('Go to login'));
    await t.pumpAndSettle();
    expect(currentLocation(t), '/login');
  });

  testWidgets('signup 410 INVITE_USED replaces the form', (t) async {
    final api = _apiWithPreview();
    api.on(
      'POST',
      '/auth/register/client',
      (_) => FakeResponse.problem(410, 'INVITE_USED'),
    );
    await pumpApp(t, api: api, initialLocation: '/join/abc');
    await _fillAndSubmit(t);
    expect(find.text('This invite was already used'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
  });

  testWidgets('other signup errors stay in the form', (t) async {
    final api = _apiWithPreview();
    api.on(
      'POST',
      '/auth/register/client',
      (_) => FakeResponse.problem(409, 'EMAIL_TAKEN'),
    );
    await pumpApp(t, api: api, initialLocation: '/join/abc');
    await _fillAndSubmit(t);
    expect(
      find.text('An account with this email already exists.'),
      findsOneWidget,
    );
  });

  testWidgets('network error on preview: banner and retry', (t) async {
    final api = FakeApi();
    api.on('GET', '/invites/abc', (_) => FakeResponse.networkError());
    await pumpApp(t, api: api, initialLocation: '/join/abc');
    expect(find.text('Retry'), findsOneWidget);
    api.on('GET', '/invites/abc', (_) => FakeResponse.json(200, _preview));
    await t.tap(find.text('Retry'));
    await t.pumpAndSettle();
    expect(
      find.text("You're joining Maria Ionescu's coaching"),
      findsOneWidget,
    );
  });

  testWidgets('signed in: notice, sign out shows preview and form', (t) async {
    final api = _apiWithPreview();
    api.on('POST', '/auth/logout', (_) => FakeResponse.empty(204));
    await _pumpSignedIn(t, api, '/join/abc');
    expect(find.text("You're signed in as ana@example.ro"), findsOneWidget);
    expect(api.count('GET', '/invites/abc'), 0);
    await t.tap(find.text('Sign out to create a new account'));
    await t.pumpAndSettle();
    expect(currentLocation(t), '/join/abc');
    expect(
      find.text("You're joining Maria Ionescu's coaching"),
      findsOneWidget,
    );
    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(api.count('GET', '/invites/abc'), 1);
  });

  testWidgets('signup sends UI locale and time zone', (t) async {
    final api = _apiWithPreview();
    _signupOk(api);
    await pumpApp(t, api: api, initialLocation: '/join/abc');
    await t.tap(find.text('RO'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextFormField).at(0), 'Ion');
    await t.enterText(find.byType(TextFormField).at(1), 'Vasile');
    await t.enterText(find.byType(TextFormField).at(2), 'ion@example.ro');
    await t.enterText(find.byType(TextFormField).at(3), 'secret-password');
    await t.tap(find.byType(FilledButton));
    await t.pumpAndSettle();
    final body = api.requests.last.data as Map;
    expect(body['locale'], 'ro');
    expect(body['timezone'], browserTimeZone());
  });

  testWidgets('success lands on home as a client', (t) async {
    final api = _apiWithPreview();
    _signupOk(api);
    await pumpApp(t, api: api, initialLocation: '/join/abc');
    await _fillAndSubmit(t);
    expect(currentLocation(t), '/home');
    expect(find.text('Hello, Ana'), findsOneWidget);
    expect(find.text('Client'), findsOneWidget);
  });
}
