import 'dart:async';

import 'package:ana_fit_lab/core/api/api_client.dart';
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

TokenResponse _token({
  String access = 'access-1',
  Duration accessValidFor = const Duration(minutes: 15),
}) => TokenResponse.fromJson(
  tokenJson(access: access, accessValidFor: accessValidFor, now: _now),
);

FakeResponse _refreshed() => FakeResponse.json(
  200,
  tokenJson(now: _now, access: 'access-2', refresh: 'refresh-2'),
);

Future<ProviderContainer> _signedIn(
  FakeApi api, {
  Duration accessValidFor = const Duration(minutes: 15),
  MemoryTokenStore? store,
}) async {
  final c = await makeContainer(api: api, store: store);
  await c
      .read(authControllerProvider.notifier)
      .applySession(_token(accessValidFor: accessValidFor));
  return c;
}

OpenapiClient _api(ProviderContainer c) => c.read(apiProvider).openapi;

String? _auth(FakeApi api, String path) =>
    api.requests
            .lastWhere((r) => r.uri.path.endsWith(path))
            .headers['Authorization']
        as String?;

void main() {
  test('dio uses 10 s connect and 20 s receive timeouts', () async {
    final c = await makeContainer(api: FakeApi());
    final options = c.read(dioProvider).options;
    expect(options.connectTimeout, const Duration(seconds: 10));
    expect(options.receiveTimeout, const Duration(seconds: 20));
  });

  test('getMe carries Bearer token and Accept-Language', () async {
    final api = FakeApi()
      ..on('GET', '/me', (_) => FakeResponse.json(200, userJson()));
    final c = await _signedIn(api);

    await apiCall(() => _api(c).getMe());
    expect(api.requests.last.headers['Authorization'], 'Bearer access-1');
    expect(api.requests.last.headers['Accept-Language'], 'en');

    c.read(localeControllerProvider.notifier).select('ro');
    await apiCall(() => _api(c).getMe());
    expect(api.requests.last.headers['Accept-Language'], 'ro');
  });

  test('public calls carry no Authorization; resend and getMe do', () async {
    final api = FakeApi()
      ..on(
        'POST',
        '/auth/login',
        (_) => FakeResponse.json(200, tokenJson(now: _now)),
      )
      ..on(
        'GET',
        '/invites/ABC',
        (_) => FakeResponse.json(200, {
          'valid': true,
          'coachFirstName': 'Ana',
          'coachLastName': 'Popescu',
        }),
      )
      ..on('POST', '/auth/logout', (_) => FakeResponse.empty(204))
      ..on('POST', '/auth/verify-email', (_) => FakeResponse.empty(204))
      ..on('POST', '/auth/verify-email/resend', (_) => FakeResponse.empty(204))
      ..on('GET', '/me', (_) => FakeResponse.json(200, userJson()));
    final c = await _signedIn(api);
    final client = _api(c);

    await apiCall(
      () => client.login(
        body: const LoginRequest(email: 'a@b.ro', password: 'secret-password'),
      ),
    );
    expect(_auth(api, '/auth/login'), isNull);
    expect(api.requests.last.headers['Accept-Language'], 'en');

    try {
      await client.previewInvite(code: 'ABC');
    } catch (_) {
      // Only the request headers matter here.
    }
    expect(_auth(api, '/invites/ABC'), isNull);

    await apiCall(
      () => client.logout(body: const LogoutRequest(refreshToken: 'x')),
    );
    expect(_auth(api, '/auth/logout'), isNull);

    await apiCall(
      () => client.verifyEmail(body: const VerifyEmailRequest(token: 't')),
    );
    expect(_auth(api, '/auth/verify-email'), isNull);

    await apiCall(() => client.resendVerificationEmail());
    expect(_auth(api, '/auth/verify-email/resend'), 'Bearer access-1');

    await apiCall(() => client.getMe());
    expect(_auth(api, '/me'), 'Bearer access-1');
  });

  test('401 on a public call is passed through without refreshing', () async {
    final api = FakeApi()
      ..on(
        'POST',
        '/auth/login',
        (_) => FakeResponse.problem(401, 'INVALID_CREDENTIALS'),
      );
    final c = await _signedIn(api);
    await expectLater(
      apiCall(
        () => _api(c).login(
          body: const LoginRequest(email: 'a@b.ro', password: 'x'),
        ),
      ),
      throwsA(
        isA<ApiError>().having((e) => e.code, 'code', 'INVALID_CREDENTIALS'),
      ),
    );
    expect(api.count('POST', '/auth/refresh'), 0);
  });

  test('proactive: token expiring in 30 s is refreshed before /me', () async {
    final api = FakeApi()
      ..on('POST', '/auth/refresh', (_) => _refreshed())
      ..on('GET', '/me', (_) => FakeResponse.json(200, userJson()));
    final c = await _signedIn(api, accessValidFor: const Duration(seconds: 30));

    await apiCall(() => _api(c).getMe());

    expect(api.requests.map((r) => '${r.method} ${r.uri.path}').toList(), [
      'POST /api/v1/auth/refresh',
      'GET /api/v1/me',
    ]);
    expect(api.requests.first.headers['Authorization'], isNull);
    expect(api.requests.last.headers['Authorization'], 'Bearer access-2');
  });

  test(
    'proactive refresh failing with NETWORK fails the call, session kept',
    () async {
      final api = FakeApi()
        ..on('POST', '/auth/refresh', (_) => FakeResponse.networkError());
      final c = await _signedIn(
        api,
        accessValidFor: const Duration(seconds: 30),
      );

      await expectLater(
        apiCall(() => _api(c).getMe()),
        throwsA(isA<ApiError>().having((e) => e.code, 'code', 'NETWORK')),
      );
      expect(api.count('GET', '/me'), 0);
      expect(c.read(authControllerProvider), isA<SignedIn>());
    },
  );

  test('401 then retry once with the new token', () async {
    var meCalls = 0;
    final api = FakeApi()
      ..on('POST', '/auth/refresh', (_) => _refreshed())
      ..on('GET', '/me', (_) {
        meCalls++;
        return meCalls == 1
            ? FakeResponse.problem(401, 'UNAUTHORIZED')
            : FakeResponse.json(200, userJson(firstName: 'Retried'));
      });
    final c = await _signedIn(api);

    final user = await apiCall(() => _api(c).getMe());

    expect(user.firstName, 'Retried');
    expect(api.count('POST', '/auth/refresh'), 1);
    expect(api.count('GET', '/me'), 2);
    expect(api.requests.last.headers['Authorization'], 'Bearer access-2');
    expect(c.read(authControllerProvider), isA<SignedIn>());
  });

  test('second 401 signs out', () async {
    final api = FakeApi()
      ..on('POST', '/auth/refresh', (_) => _refreshed())
      ..on('POST', '/auth/logout', (_) => FakeResponse.empty(204))
      ..on('GET', '/me', (_) => FakeResponse.problem(401, 'UNAUTHORIZED'));
    final store = MemoryTokenStore();
    final c = await _signedIn(api, store: store);

    await expectLater(
      apiCall(() => _api(c).getMe()),
      throwsA(isA<ApiError>().having((e) => e.status, 'status', 401)),
    );
    expect(
      c.read(authControllerProvider),
      const SignedOut(reason: SignedOutReason.sessionEnded),
    );
    expect(api.count('POST', '/auth/refresh'), 1);
    expect(api.count('GET', '/me'), 2);
    expect(await store.read(), isNull);
  });

  test('401 whose refresh is rejected signs out and fails the call', () async {
    final api = FakeApi()
      ..on(
        'POST',
        '/auth/refresh',
        (_) => FakeResponse.problem(401, 'REFRESH_TOKEN_REUSED'),
      )
      ..on('GET', '/me', (_) => FakeResponse.problem(401, 'UNAUTHORIZED'));
    final c = await _signedIn(api);

    await expectLater(
      apiCall(() => _api(c).getMe()),
      throwsA(isA<ApiError>().having((e) => e.status, 'status', 401)),
    );
    expect(
      c.read(authControllerProvider),
      const SignedOut(reason: SignedOutReason.sessionEnded),
    );
    expect(api.count('GET', '/me'), 1);
  });

  test('two parallel 401s share exactly one refresh', () async {
    final refreshGate = Completer<void>();
    final api = FakeApi()
      ..on('POST', '/auth/refresh', (_) async {
        await refreshGate.future;
        return _refreshed();
      })
      ..on(
        'GET',
        '/me',
        (r) => r.headers['Authorization'] == 'Bearer access-2'
            ? FakeResponse.json(200, userJson())
            : FakeResponse.problem(401, 'UNAUTHORIZED'),
      );
    final c = await _signedIn(api);

    final a = apiCall(() => _api(c).getMe());
    final b = apiCall(() => _api(c).getMe());
    await pumpEventQueue();
    refreshGate.complete();
    await Future.wait([a, b]);

    expect(api.count('POST', '/auth/refresh'), 1);
    expect(api.count('GET', '/me'), 4);
  });

  test(
    'a late 401 for an already-replaced token retries without refreshing',
    () async {
      final gate = Completer<void>();
      final api = FakeApi()
        ..on('GET', '/me', (r) async {
          if (r.headers['Authorization'] == 'Bearer access-2') {
            return FakeResponse.json(200, userJson());
          }
          await gate.future;
          return FakeResponse.problem(401, 'UNAUTHORIZED');
        });
      final c = await _signedIn(api);
      final first = apiCall(() => _api(c).getMe());
      while (api.requests.isEmpty) {
        await pumpEventQueue();
      }
      // Another call refreshed the session before this 401 arrives.
      await c
          .read(authControllerProvider.notifier)
          .applySession(_token(access: 'access-2'));
      gate.complete();
      await first;
      expect(api.count('POST', '/auth/refresh'), 0);
      expect(api.count('GET', '/me'), 2);
    },
  );
}
