import 'dart:ui';

import 'package:ana_fit_lab/core/api/generated/export.dart';
import 'package:ana_fit_lab/core/auth/auth_controller.dart';
import 'package:ana_fit_lab/core/auth/token_store.dart';
import 'package:ana_fit_lab/core/errors/api_error.dart';
import 'package:ana_fit_lab/core/locale/locale_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_container.dart';
import '../../support/fake_api.dart';
import '../../support/fixtures.dart';

final _now = testNow;
final _future = _now.add(const Duration(days: 10));

TokenResponse _token({
  String access = 'access-1',
  String refresh = 'refresh-1',
  Duration accessValidFor = const Duration(minutes: 15),
  Map<String, dynamic>? user,
}) => TokenResponse.fromJson(
  tokenJson(
    access: access,
    refresh: refresh,
    accessValidFor: accessValidFor,
    user: user,
    now: _now,
  ),
);

AuthController _auth(ProviderContainer c) =>
    c.read(authControllerProvider.notifier);

Matcher _apiError(String code) =>
    isA<ApiError>().having((e) => e.code, 'code', code);

void main() {
  test('initial state is AuthUnknown (not unreachable)', () async {
    final c = await makeContainer(api: FakeApi());
    expect(c.read(authControllerProvider), const AuthUnknown());
  });

  group('start', () {
    test('without a stored token -> SignedOut, no request', () async {
      final api = FakeApi();
      final c = await makeContainer(api: api);
      await _auth(c).start();
      expect(c.read(authControllerProvider), const SignedOut());
      expect(api.requests, isEmpty);
    });

    test('with an expired stored token -> SignedOut, store cleared', () async {
      final api = FakeApi();
      final store = MemoryTokenStore();
      await store.write('r1', _now.subtract(const Duration(minutes: 1)));
      final c = await makeContainer(api: api, store: store);
      await _auth(c).start();
      expect(c.read(authControllerProvider), const SignedOut());
      expect(api.requests, isEmpty);
      expect(await store.read(), isNull);
    });

    test(
      'with a valid token -> refresh, SignedIn, locale follows user',
      () async {
        final api = FakeApi();
        final store = MemoryTokenStore();
        await store.write('r1', _future);
        Object? sent;
        api.on('POST', '/auth/refresh', (r) {
          sent = r.data;
          return FakeResponse.json(
            200,
            tokenJson(
              now: _now,
              user: userJson(locale: 'ro'),
            ),
          );
        });
        final c = await makeContainer(api: api, store: store);
        await _auth(c).start();

        expect(sent, {'refreshToken': 'r1'});
        final state = c.read(authControllerProvider);
        expect(state, isA<SignedIn>());
        expect((state as SignedIn).user.locale, UserResponseLocale.ro);
        expect((await store.read())!.token, 'refresh-1');
        expect(_auth(c).session!.accessToken, 'access-1');
        expect(c.read(localeControllerProvider), const Locale('ro'));
        expect(api.requests.single.headers['Authorization'], isNull);
      },
    );

    test('with a rejected token (401) -> SignedOut, store cleared', () async {
      final api = FakeApi()
        ..on(
          'POST',
          '/auth/refresh',
          (_) => FakeResponse.problem(401, 'INVALID_REFRESH_TOKEN'),
        );
      final store = MemoryTokenStore();
      await store.write('r1', _future);
      final c = await makeContainer(api: api, store: store);
      await _auth(c).start();
      expect(c.read(authControllerProvider), const SignedOut());
      expect(await store.read(), isNull);
    });

    test('suspended (403) -> SignedOut(suspended), store cleared', () async {
      final api = FakeApi()
        ..on(
          'POST',
          '/auth/refresh',
          (_) => FakeResponse.problem(403, 'ACCOUNT_SUSPENDED'),
        );
      final store = MemoryTokenStore();
      await store.write('r1', _future);
      final c = await makeContainer(api: api, store: store);
      await _auth(c).start();
      expect(
        c.read(authControllerProvider),
        const SignedOut(reason: SignedOutReason.suspended),
      );
      expect(await store.read(), isNull);
    });

    test('keeps the token on a network error; retry recovers', () async {
      var down = true;
      final api = FakeApi()
        ..on(
          'POST',
          '/auth/refresh',
          (_) => down
              ? FakeResponse.networkError()
              : FakeResponse.json(200, tokenJson(now: _now)),
        );
      final store = MemoryTokenStore();
      await store.write('r1', _future);
      final c = await makeContainer(api: api, store: store);

      await _auth(c).start();
      expect(
        c.read(authControllerProvider),
        const AuthUnknown(unreachable: true),
      );
      expect((await store.read())!.token, 'r1');

      down = false;
      await _auth(c).start();
      expect(c.read(authControllerProvider), isA<SignedIn>());
      expect((await store.read())!.token, 'refresh-1');
    });

    test('keeps the token on a server error (500)', () async {
      final api = FakeApi()
        ..on(
          'POST',
          '/auth/refresh',
          (_) => FakeResponse.problem(500, 'INTERNAL_ERROR'),
        );
      final store = MemoryTokenStore();
      await store.write('r1', _future);
      final c = await makeContainer(api: api, store: store);
      await _auth(c).start();
      expect(
        c.read(authControllerProvider),
        const AuthUnknown(unreachable: true),
      );
      expect((await store.read())!.token, 'r1');
    });
  });

  test(
    'start: 403 with a non-JSON body keeps the token (unreachable)',
    () async {
      final api = FakeApi()
        ..on(
          'POST',
          '/auth/refresh',
          (_) => FakeResponse.html(403, '<html>Forbidden</html>'),
        );
      final store = MemoryTokenStore();
      await store.write('r1', _future);
      final c = await makeContainer(api: api, store: store);
      await _auth(c).start();
      expect(
        c.read(authControllerProvider),
        const AuthUnknown(unreachable: true),
      );
      expect((await store.read())!.token, 'r1');
    },
  );

  group('login', () {
    test('success -> SignedIn with the response session', () async {
      Object? sent;
      final api = FakeApi()
        ..on('POST', '/auth/login', (r) {
          sent = r.data;
          return FakeResponse.json(200, tokenJson(now: _now));
        });
      final store = MemoryTokenStore();
      final c = await makeContainer(api: api, store: store);
      await _auth(c).start();
      await _auth(c).login('ana@example.ro', 'secret-password');

      expect(sent, {'email': 'ana@example.ro', 'password': 'secret-password'});
      expect(c.read(authControllerProvider), isA<SignedIn>());
      expect(_auth(c).session!.accessToken, 'access-1');
      expect(_auth(c).session!.refreshToken, 'refresh-1');
      expect((await store.read())!.token, 'refresh-1');
    });

    test('401 -> throws INVALID_CREDENTIALS, state unchanged', () async {
      final api = FakeApi()
        ..on(
          'POST',
          '/auth/login',
          (_) => FakeResponse.problem(401, 'INVALID_CREDENTIALS'),
        );
      final c = await makeContainer(api: api);
      await _auth(c).start();
      await expectLater(
        _auth(c).login('ana@example.ro', 'wrong-password'),
        throwsA(_apiError('INVALID_CREDENTIALS')),
      );
      expect(c.read(authControllerProvider), const SignedOut());
      expect(api.count('POST', '/auth/refresh'), 0);
    });
  });

  test('registerCoach applies the returned session', () async {
    final api = FakeApi()
      ..on(
        'POST',
        '/auth/register/coach',
        (_) => FakeResponse.json(201, tokenJson(now: _now)),
      );
    final c = await makeContainer(api: api);
    await _auth(c).registerCoach(
      const RegisterCoachRequest(
        email: 'ana@example.ro',
        password: 'secret-password',
        firstName: 'Ana',
        lastName: 'Popescu',
        locale: RegisterCoachRequestLocale.en,
        timezone: 'Europe/Bucharest',
      ),
    );
    expect(c.read(authControllerProvider), isA<SignedIn>());
  });

  test('confirmPasswordReset applies the returned session', () async {
    Object? sent;
    final api = FakeApi()
      ..on('POST', '/auth/password-reset/confirm', (r) {
        sent = r.data;
        return FakeResponse.json(200, tokenJson(now: _now));
      });
    final c = await makeContainer(api: api);
    await _auth(c).confirmPasswordReset('tok', 'new-password-1');
    expect(sent, {'token': 'tok', 'newPassword': 'new-password-1'});
    expect(c.read(authControllerProvider), isA<SignedIn>());
  });

  group('logout', () {
    test('posts the refresh token, clears store and session', () async {
      Object? sent;
      final api = FakeApi()
        ..on('POST', '/auth/logout', (r) {
          sent = r.data;
          return FakeResponse.empty(204);
        });
      final store = MemoryTokenStore();
      final c = await makeContainer(api: api, store: store);
      await _auth(c).applySession(_token());

      await _auth(c).logout();

      expect(sent, {'refreshToken': 'refresh-1'});
      expect(api.requests.single.headers['Authorization'], isNull);
      expect(await store.read(), isNull);
      expect(_auth(c).session, isNull);
      expect(c.read(authControllerProvider), const SignedOut());
    });

    test('still signs out when the call fails with NETWORK', () async {
      final api = FakeApi()
        ..on('POST', '/auth/logout', (_) => FakeResponse.networkError());
      final store = MemoryTokenStore();
      final c = await makeContainer(api: api, store: store);
      await _auth(c).applySession(_token());

      await _auth(c).logout(reason: SignedOutReason.sessionEnded);

      expect(await store.read(), isNull);
      expect(
        c.read(authControllerProvider),
        const SignedOut(reason: SignedOutReason.sessionEnded),
      );
    });

    test('while unreachable revokes the stored token', () async {
      Object? sent;
      final api = FakeApi()
        ..on('POST', '/auth/refresh', (_) => FakeResponse.networkError())
        ..on('POST', '/auth/logout', (r) {
          sent = r.data;
          return FakeResponse.empty(204);
        });
      final store = MemoryTokenStore();
      await store.write('r1', _future);
      final c = await makeContainer(api: api, store: store);
      await _auth(c).start();

      await _auth(c).logout();

      expect(sent, {'refreshToken': 'r1'});
      expect(await store.read(), isNull);
      expect(c.read(authControllerProvider), const SignedOut());
    });
  });

  group('validAccessToken / refresh failures', () {
    Future<ProviderContainer> signedInExpiring(
      FakeApi api,
      MemoryTokenStore store,
    ) async {
      final c = await makeContainer(api: api, store: store);
      await _auth(c)
          .applySession(_token(accessValidFor: const Duration(seconds: 30)));
      return c;
    }

    test('returns the current token without refreshing when fresh', () async {
      final api = FakeApi();
      final c = await makeContainer(api: api);
      await _auth(c).applySession(_token());
      expect(await _auth(c).validAccessToken(), 'access-1');
      expect(api.requests, isEmpty);
    });

    test('returns null when signed out', () async {
      final c = await makeContainer(api: FakeApi());
      expect(await _auth(c).validAccessToken(), isNull);
    });

    test('refreshes when expiring within 60 s', () async {
      final api = FakeApi()
        ..on(
          'POST',
          '/auth/refresh',
          (_) => FakeResponse.json(
            200,
            tokenJson(now: _now, access: 'access-2', refresh: 'refresh-2'),
          ),
        );
      final store = MemoryTokenStore();
      final c = await signedInExpiring(api, store);
      expect(await _auth(c).validAccessToken(), 'access-2');
      expect(_auth(c).session!.refreshToken, 'refresh-2');
      expect((await store.read())!.token, 'refresh-2');
    });

    test('REFRESH_TOKEN_REUSED -> SignedOut(sessionEnded)', () async {
      final api = FakeApi()
        ..on(
          'POST',
          '/auth/refresh',
          (_) => FakeResponse.problem(401, 'REFRESH_TOKEN_REUSED'),
        );
      final store = MemoryTokenStore();
      final c = await signedInExpiring(api, store);
      expect(await _auth(c).validAccessToken(), isNull);
      expect(
        c.read(authControllerProvider),
        const SignedOut(reason: SignedOutReason.sessionEnded),
      );
      expect(await store.read(), isNull);
      expect(_auth(c).session, isNull);
    });

    test('ACCOUNT_SUSPENDED (403) -> SignedOut(suspended)', () async {
      final api = FakeApi()
        ..on(
          'POST',
          '/auth/refresh',
          (_) => FakeResponse.problem(403, 'ACCOUNT_SUSPENDED'),
        );
      final store = MemoryTokenStore();
      final c = await signedInExpiring(api, store);
      expect(await _auth(c).validAccessToken(), isNull);
      expect(
        c.read(authControllerProvider),
        const SignedOut(reason: SignedOutReason.suspended),
      );
      expect(await store.read(), isNull);
    });

    test('NETWORK -> throws, session kept', () async {
      final api = FakeApi()
        ..on('POST', '/auth/refresh', (_) => FakeResponse.networkError());
      final store = MemoryTokenStore();
      final c = await signedInExpiring(api, store);
      await expectLater(
        _auth(c).validAccessToken(),
        throwsA(_apiError('NETWORK')),
      );
      expect(c.read(authControllerProvider), isA<SignedIn>());
      expect(_auth(c).session!.accessToken, 'access-1');
      expect((await store.read())!.token, 'refresh-1');
    });

    test('refreshAfterUnauthorized returns the current token when it '
        'already differs from the rejected one', () async {
      final api = FakeApi();
      final c = await makeContainer(api: api);
      await _auth(c).applySession(_token(access: 'access-2'));
      expect(await _auth(c).refreshAfterUnauthorized('access-1'), 'access-2');
      expect(api.requests, isEmpty);
    });

    test('logout during an in-flight refresh leaves the store empty', () async {
      final api = FakeApi()
        ..on('POST', '/auth/refresh', (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return FakeResponse.json(
            200,
            tokenJson(now: _now, access: 'access-2', refresh: 'refresh-2'),
          );
        })
        ..on('POST', '/auth/logout', (_) => FakeResponse.empty(204));
      final store = MemoryTokenStore();
      final c = await signedInExpiring(api, store);

      final pending = _auth(c).validAccessToken();
      await Future<void>.delayed(const Duration(milliseconds: 1));
      await _auth(c).logout();

      expect(await pending, isNull);
      expect(await store.read(), isNull);
      expect(_auth(c).session, isNull);
      expect(c.read(authControllerProvider), const SignedOut());
    });
  });

  test('in-session refresh: 403 with a non-JSON body rethrows, session '
      'and token kept', () async {
    final api = FakeApi()
      ..on(
        'POST',
        '/auth/refresh',
        (_) => FakeResponse.html(403, '<html>Forbidden</html>'),
      );
    final store = MemoryTokenStore();
    final c = await makeContainer(api: api, store: store);
    await _auth(c)
        .applySession(_token(accessValidFor: const Duration(seconds: 30)));
    await expectLater(
      _auth(c).validAccessToken(),
      throwsA(_apiError('INTERNAL_ERROR')),
    );
    expect(c.read(authControllerProvider), isA<SignedIn>());
    expect(_auth(c).session, isNotNull);
    expect((await store.read())!.token, 'refresh-1');
  });

  group('user locale', () {
    test('a refresh of the same user keeps a manual language choice', () async {
      final api = FakeApi()
        ..on(
          'POST',
          '/auth/refresh',
          (_) => FakeResponse.json(
            200,
            tokenJson(now: _now, access: 'access-2', refresh: 'refresh-2'),
          ),
        );
      final c = await makeContainer(api: api);
      await _auth(c)
          .applySession(_token(accessValidFor: const Duration(seconds: 30)));
      expect(c.read(localeControllerProvider), const Locale('en'));

      c.read(localeControllerProvider.notifier).select('ro');
      expect(await _auth(c).validAccessToken(), 'access-2');
      expect(c.read(localeControllerProvider), const Locale('ro'));
    });

    test('login applies the user locale', () async {
      final api = FakeApi()
        ..on(
          'POST',
          '/auth/login',
          (_) => FakeResponse.json(200, tokenJson(now: _now)),
        );
      final c = await makeContainer(api: api, prefs: {'locale': 'ro'});
      await _auth(c).start();
      expect(c.read(localeControllerProvider), const Locale('ro'));
      await _auth(c).login('ana@example.ro', 'secret-password');
      expect(c.read(localeControllerProvider), const Locale('en'));
    });

    test('a different user signing in applies their locale', () async {
      final c = await makeContainer(api: FakeApi());
      await _auth(c).applySession(_token());
      c.read(localeControllerProvider.notifier).select('en');
      final other = userJson(locale: 'ro')
        ..['id'] = '22222222-2222-2222-2222-222222222222';
      await _auth(c).applySession(_token(user: other));
      expect(c.read(localeControllerProvider), const Locale('ro'));
    });
  });

  test('reloadUser replaces the user from GET /me', () async {
    final api = FakeApi()
      ..on(
        'GET',
        '/me',
        (_) => FakeResponse.json(200, userJson(status: 'ACTIVE')),
      );
    final c = await makeContainer(api: api);
    await _auth(c).applySession(_token());
    await _auth(c).reloadUser();
    final state = c.read(authControllerProvider) as SignedIn;
    expect(state.user.status, UserResponseStatus.active);
    expect(_auth(c).session!.user.status, UserResponseStatus.active);
  });
}
