import 'package:flutter/material.dart';
import 'package:ana_fit_lab/core/auth/token_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_container.dart';
import '../../support/fake_api.dart';
import '../../support/fixtures.dart';
import '../../support/test_app.dart';

const _reset = '/reset-password?token=tok';
const _strong = 'a-long-password';

Future<void> _fillReset(
  WidgetTester t, {
  String password = _strong,
  String confirm = _strong,
}) async {
  await t.enterText(find.byType(TextFormField).at(0), password);
  await t.enterText(find.byType(TextFormField).at(1), confirm);
  await t.tap(find.widgetWithText(FilledButton, 'Set new password'));
  await t.pumpAndSettle();
}

Future<void> _fillForgot(WidgetTester t, String email) async {
  await t.enterText(find.byType(TextFormField), email);
  await t.tap(find.widgetWithText(FilledButton, 'Send reset link'));
  await t.pumpAndSettle();
}

FakeApi _confirmApi(FakeResponse Function() r) {
  final api = FakeApi();
  api.on('POST', '/auth/password-reset/confirm', (_) => r());
  return api;
}

FakeResponse _session({String first = 'Ana', String refresh = 'refresh-new'}) =>
    FakeResponse.json(
      200,
      tokenJson(
        now: testNow,
        refresh: refresh,
        user: userJson(status: 'ACTIVE', firstName: first),
      ),
    );

void main() {
  group('forgot', () {
    testWidgets('invalid email shows an error and sends nothing', (t) async {
      final api = FakeApi();
      await pumpApp(t, api: api, initialLocation: '/forgot-password');
      await _fillForgot(t, 'nope');
      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(api.requests, isEmpty);
    });

    testWidgets('202 replaces the form with the sent text', (t) async {
      final api = FakeApi();
      api.on(
        'POST',
        '/auth/password-reset/request',
        (_) => FakeResponse.empty(202),
      );
      await pumpApp(t, api: api, initialLocation: '/forgot-password');
      await _fillForgot(t, '  ana@example.ro ');
      expect((api.requests.last.data as Map)['email'], 'ana@example.ro');
      expect(find.textContaining("we've sent a link"), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);
      await t.tap(find.text('Go to login'));
      await t.pumpAndSettle();
      expect(currentLocation(t), '/login');
    });

    testWidgets('429 shows the rate limit message and keeps the form', (
      t,
    ) async {
      final api = FakeApi();
      api.on(
        'POST',
        '/auth/password-reset/request',
        (_) => FakeResponse.problem(429, 'RATE_LIMITED', retryAfterSeconds: 60),
      );
      await pumpApp(t, api: api, initialLocation: '/forgot-password');
      await _fillForgot(t, 'ana@example.ro');
      expect(find.textContaining('Too many attempts'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Go to login'), findsOneWidget);
    });
  });

  group('reset', () {
    testWidgets('mismatch shows an error and sends nothing', (t) async {
      final api = FakeApi();
      await pumpApp(t, api: api, initialLocation: _reset);
      await _fillReset(t, confirm: 'something-else-1');
      expect(find.text("Passwords don't match"), findsOneWidget);
      expect(api.requests, isEmpty);
    });

    testWidgets('short password fails the policy client-side', (t) async {
      final api = FakeApi();
      await pumpApp(t, api: api, initialLocation: _reset);
      await _fillReset(t, password: 'short', confirm: 'short');
      expect(find.text('Use 10–64 characters'), findsOneWidget);
      expect(api.requests, isEmpty);
    });

    testWidgets('INVALID_TOKEN shows the invalid view and links to forgot', (
      t,
    ) async {
      final api = _confirmApi(() => FakeResponse.problem(400, 'INVALID_TOKEN'));
      await pumpApp(t, api: api, initialLocation: _reset);
      await _fillReset(t);
      expect(
        find.text('This reset link is invalid or has expired'),
        findsOneWidget,
      );
      await t.tap(find.text('Request a new link'));
      await t.pumpAndSettle();
      expect(currentLocation(t), '/forgot-password');
    });

    testWidgets('ACCOUNT_SUSPENDED shows a banner', (t) async {
      final api = _confirmApi(
        () => FakeResponse.problem(403, 'ACCOUNT_SUSPENDED'),
      );
      await pumpApp(t, api: api, initialLocation: _reset);
      await _fillReset(t);
      expect(find.text('Your account is suspended.'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('server PASSWORD_POLICY shows under the field', (t) async {
      final api = _confirmApi(
        () => FakeResponse.problem(
          400,
          'VALIDATION_FAILED',
          errors: [
            {'field': 'newPassword', 'code': 'PASSWORD_POLICY'},
          ],
        ),
      );
      await pumpApp(t, api: api, initialLocation: _reset);
      await _fillReset(t);
      expect(api.count('POST', '/auth/password-reset/confirm'), 1);
      expect(find.text('Use 10–64 characters'), findsOneWidget);
    });

    testWidgets('success signs in and goes home', (t) async {
      final api = _confirmApi(_session);
      await pumpApp(t, api: api, initialLocation: _reset);
      await _fillReset(t);
      final body = api.requests.last.data as Map;
      expect(body['token'], 'tok');
      expect(body['newPassword'], _strong);
      expect(currentLocation(t), '/home');
      expect(find.text('Hello, Ana'), findsOneWidget);
    });

    testWidgets(
      'success while another user is signed in replaces the session',
      (t) async {
        final store = MemoryTokenStore();
        await store.write('r1', testNow.add(const Duration(days: 10)));
        final api = _confirmApi(() => _session(first: 'Maria'));
        api.on(
          'POST',
          '/auth/refresh',
          (_) => FakeResponse.json(
            200,
            tokenJson(
              now: testNow,
              user: userJson(status: 'ACTIVE', firstName: 'Ana'),
            ),
          ),
        );
        await pumpApp(t, api: api, store: store, initialLocation: _reset);
        expect(currentLocation(t), _reset);
        await _fillReset(t);
        expect(currentLocation(t), '/home');
        expect(find.text('Hello, Maria'), findsOneWidget);
        expect((await store.read())!.token, 'refresh-new');
      },
    );

    for (final loc in ['/reset-password', '/reset-password?token=']) {
      testWidgets('missing token ($loc) shows invalid with no request', (
        t,
      ) async {
        final api = FakeApi();
        await pumpApp(t, api: api, initialLocation: loc);
        expect(
          find.text('This reset link is invalid or has expired'),
          findsOneWidget,
        );
        expect(api.requests, isEmpty);
      });
    }
  });
}
