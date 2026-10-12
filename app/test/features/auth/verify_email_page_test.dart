import 'package:ana_fit_lab/core/auth/token_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_container.dart';
import '../../support/fake_api.dart';
import '../../support/fixtures.dart';
import '../../support/test_app.dart';

const _loc = '/verify-email?token=tok';

FakeApi _verify(FakeResponse Function() r) {
  final api = FakeApi();
  api.on('POST', '/auth/verify-email', (_) => r());
  return api;
}

Future<void> _pumpSignedIn(
  WidgetTester t,
  FakeApi api, {
  String status = 'PENDING',
  String location = _loc,
}) async {
  final store = MemoryTokenStore();
  await store.write('r1', testNow.add(const Duration(days: 10)));
  api.on(
    'POST',
    '/auth/refresh',
    (_) => FakeResponse.json(
      200,
      tokenJson(
        now: testNow,
        user: userJson(status: status),
      ),
    ),
  );
  await pumpApp(t, api: api, store: store, initialLocation: location);
}

void main() {
  testWidgets('success signed out shows confirmation and goes to login', (
    t,
  ) async {
    final api = _verify(() => FakeResponse.empty(204));
    await pumpApp(t, api: api, initialLocation: _loc);
    expect(find.text('Email confirmed'), findsOneWidget);
    expect(find.text('Your account is ready.'), findsOneWidget);
    expect((api.requests.last.data as Map)['token'], 'tok');
    await t.tap(find.text('Go to login'));
    await t.pumpAndSettle();
    expect(currentLocation(t), '/login');
  });

  testWidgets('success signed in reloads the user then goes home', (t) async {
    final api = _verify(() => FakeResponse.empty(204));
    api.on(
      'GET',
      '/me',
      (_) => FakeResponse.json(200, userJson(status: 'ACTIVE')),
    );
    await _pumpSignedIn(t, api);
    expect(api.count('GET', '/me'), 1);
    expect(find.text('Email confirmed'), findsOneWidget);
    await t.tap(find.text('Go home'));
    await t.pumpAndSettle();
    expect(currentLocation(t), '/home');
  });

  testWidgets('success signed in still confirms when reloading fails', (
    t,
  ) async {
    final api = _verify(() => FakeResponse.empty(204));
    api.on('GET', '/me', (_) => FakeResponse.problem(500, 'INTERNAL_ERROR'));
    await _pumpSignedIn(t, api);
    expect(find.text('Email confirmed'), findsOneWidget);
    expect(find.text('Go home'), findsOneWidget);
  });

  testWidgets('verify is called once even when auth state changes', (t) async {
    final api = _verify(() => FakeResponse.empty(204));
    api.on(
      'GET',
      '/me',
      (_) => FakeResponse.json(200, userJson(status: 'ACTIVE')),
    );
    await _pumpSignedIn(t, api);
    await t.pumpAndSettle();
    expect(api.count('POST', '/auth/verify-email'), 1);
  });

  testWidgets('INVALID_TOKEN signed in PENDING offers resend', (t) async {
    final api = _verify(() => FakeResponse.problem(400, 'INVALID_TOKEN'));
    api.on('POST', '/auth/verify-email/resend', (_) => FakeResponse.empty(204));
    await _pumpSignedIn(t, api);
    expect(
      find.text('This confirmation link is invalid or has expired'),
      findsOneWidget,
    );
    expect(find.text('We can send you a new link.'), findsOneWidget);
    await t.tap(find.text('Resend'));
    await t.pumpAndSettle();
    expect(find.text('Sent'), findsOneWidget);
    expect(api.count('POST', '/auth/verify-email/resend'), 1);
    expect(api.count('POST', '/auth/verify-email'), 1);
  });

  testWidgets('resend rate limited shows the error', (t) async {
    final api = _verify(() => FakeResponse.problem(400, 'INVALID_TOKEN'));
    api.on(
      'POST',
      '/auth/verify-email/resend',
      (_) => FakeResponse.problem(429, 'RATE_LIMITED', retryAfterSeconds: 600),
    );
    await _pumpSignedIn(t, api);
    await t.tap(find.text('Resend'));
    await t.pumpAndSettle();
    expect(find.textContaining('Too many attempts'), findsOneWidget);
    expect(find.text('Resend'), findsOneWidget);
  });

  testWidgets('INVALID_TOKEN signed in ACTIVE says already confirmed', (
    t,
  ) async {
    final api = _verify(() => FakeResponse.problem(400, 'INVALID_TOKEN'));
    await _pumpSignedIn(t, api, status: 'ACTIVE');
    expect(find.text('Your email is already confirmed.'), findsOneWidget);
    await t.tap(find.text('Go home'));
    await t.pumpAndSettle();
    expect(currentLocation(t), '/home');
  });

  testWidgets('INVALID_TOKEN signed out offers login', (t) async {
    final api = _verify(() => FakeResponse.problem(400, 'INVALID_TOKEN'));
    await pumpApp(t, api: api, initialLocation: _loc);
    expect(
      find.text('This confirmation link is invalid or has expired'),
      findsOneWidget,
    );
    expect(find.text('Resend'), findsNothing);
    await t.tap(find.text('Go to login'));
    await t.pumpAndSettle();
    expect(currentLocation(t), '/login');
  });

  for (final loc in ['/verify-email', '/verify-email?token=']) {
    testWidgets('missing token ($loc) shows invalid with no request', (
      t,
    ) async {
      final api = FakeApi();
      await pumpApp(t, api: api, initialLocation: loc);
      expect(
        find.text('This confirmation link is invalid or has expired'),
        findsOneWidget,
      );
      expect(api.requests, isEmpty);
    });
  }

  testWidgets('network error shows a retry that re-runs verify', (t) async {
    var calls = 0;
    final api = _verify(
      () =>
          ++calls == 1 ? FakeResponse.networkError() : FakeResponse.empty(204),
    );
    await pumpApp(t, api: api, initialLocation: _loc);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Email confirmed'), findsNothing);
    await t.tap(find.text('Retry'));
    await t.pumpAndSettle();
    expect(find.text('Email confirmed'), findsOneWidget);
    expect(api.count('POST', '/auth/verify-email'), 2);
  });
}
