import 'dart:async';

import 'package:ana_fit_lab/core/auth/auth_controller.dart';
import 'package:ana_fit_lab/core/auth/token_store.dart';
import 'package:ana_fit_lab/core/routing/router.dart';
import 'package:ana_fit_lab/features/auth/login/login_page.dart';
import 'package:ana_fit_lab/features/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_container.dart';
import '../../support/fake_api.dart';
import '../../support/fixtures.dart';
import '../../support/test_app.dart';

/// A stored refresh token plus a `/auth/refresh` handler: start() signs in.
Future<MemoryTokenStore> _signedInStore(FakeApi api) async {
  final store = MemoryTokenStore();
  await store.write('r1', testNow.add(const Duration(days: 10)));
  api.on(
    'POST',
    '/auth/refresh',
    (_) => FakeResponse.json(200, tokenJson(now: testNow)),
  );
  return store;
}

Future<FakeApi> _pumpSignedIn(WidgetTester t, String location) async {
  final api = FakeApi();
  await pumpApp(
    t,
    api: api,
    store: await _signedInStore(api),
    initialLocation: location,
  );
  return api;
}

void main() {
  group('guards', () {
    testWidgets('signed out at /home -> login with from', (t) async {
      await pumpApp(t, initialLocation: '/home');
      expect(currentLocation(t), '/login?from=%2Fhome');
      expect(find.byType(LoginPage), findsOneWidget);
    });

    for (final path in ['/login', '/register', '/forgot-password']) {
      testWidgets('signed in at $path -> /home', (t) async {
        await _pumpSignedIn(t, path);
        expect(currentLocation(t), '/home');
        expect(find.byType(HomePage), findsOneWidget);
      });
    }

    testWidgets('signed in at /login?from=<in-app path> -> from', (t) async {
      await _pumpSignedIn(t, '/login?from=%2Fjoin%2Fabc');
      expect(currentLocation(t), '/join/abc');
    });

    testWidgets('signed in at /login?from=<external> -> /home', (t) async {
      await _pumpSignedIn(t, '/login?from=https%3A%2F%2Fevil.com');
      expect(currentLocation(t), '/home');
    });

    testWidgets('/ -> /login signed out', (t) async {
      await pumpApp(t, initialLocation: '/');
      expect(currentLocation(t), '/login');
    });

    testWidgets('/ -> /home signed in', (t) async {
      await _pumpSignedIn(t, '/');
      expect(currentLocation(t), '/home');
    });

    testWidgets('unknown route -> /login signed out', (t) async {
      await pumpApp(t, initialLocation: '/nope');
      expect(currentLocation(t), '/login');
    });

    testWidgets('unknown route -> /home signed in', (t) async {
      await _pumpSignedIn(t, '/nope/deeper');
      expect(currentLocation(t), '/home');
    });

    testWidgets('/loading when known -> its target, never loops', (t) async {
      await pumpApp(t, initialLocation: '/loading?to=%2Floading');
      expect(currentLocation(t), '/login');
    });

    testWidgets('/loading with an external target -> /', (t) async {
      await _pumpSignedIn(t, '/loading?to=%2F%2Fevil.com');
      expect(currentLocation(t), '/home');
    });

    const anyone = {'/reset-password?token=x': 'reset-password'};
    anyone.forEach((location, name) {
      testWidgets('$location reachable signed out', (t) async {
        await pumpApp(t, initialLocation: location);
        expect(currentLocation(t), location);
        expect(find.text(name), findsOneWidget);
      });

      testWidgets('$location reachable signed in', (t) async {
        await _pumpSignedIn(t, location);
        expect(currentLocation(t), location);
        expect(find.text(name), findsOneWidget);
      });
    });

    testWidgets('/verify-email?token=x reachable signed out', (t) async {
      final api = FakeApi();
      api.on('POST', '/auth/verify-email', (_) => FakeResponse.empty(204));
      await pumpApp(t, api: api, initialLocation: '/verify-email?token=x');
      expect(currentLocation(t), '/verify-email?token=x');
      expect(find.text('Email confirmed'), findsOneWidget);
    });

    testWidgets('/verify-email?token=x reachable signed in', (t) async {
      final api = FakeApi();
      api.on('POST', '/auth/verify-email', (_) => FakeResponse.empty(204));
      api.on('GET', '/me', (_) => FakeResponse.json(200, userJson()));
      await pumpApp(
        t,
        api: api,
        store: await _signedInStore(api),
        initialLocation: '/verify-email?token=x',
      );
      expect(currentLocation(t), '/verify-email?token=x');
      expect(find.text('Email confirmed'), findsOneWidget);
    });

    testWidgets('/join/abc reachable signed out', (t) async {
      final api = FakeApi();
      api.on(
        'GET',
        '/invites/abc',
        (_) => FakeResponse.problem(404, 'INVITE_NOT_FOUND'),
      );
      await pumpApp(t, api: api, initialLocation: '/join/abc');
      expect(currentLocation(t), '/join/abc');
      expect(find.text("We couldn't find this invite"), findsOneWidget);
    });

    testWidgets('/join/abc reachable signed in', (t) async {
      await _pumpSignedIn(t, '/join/abc');
      expect(currentLocation(t), '/join/abc');
      expect(find.text("You're signed in as ana@example.ro"), findsOneWidget);
    });

    testWidgets('signing out on /home -> login (router follows auth)', (
      t,
    ) async {
      final api = await _pumpSignedIn(t, '/home');
      api.on('POST', '/auth/logout', (_) => FakeResponse.empty(204));
      final router = appContainer(t).read(routerProvider);

      // Not awaited directly: Dio needs (fake) time to pass, i.e. pumps.
      final done = appContainer(t)
          .read(authControllerProvider.notifier)
          .logout();
      await t.pumpAndSettle();
      await done;
      expect(currentLocation(t), '/login?from=%2Fhome');
      // Created once: auth changes refresh it, never rebuild it.
      expect(appContainer(t).read(routerProvider), same(router));
    });
  });

  group('splash', () {
    testWidgets('pending start shows splash, then the requested page', (
      t,
    ) async {
      final api = FakeApi();
      final store = MemoryTokenStore();
      await store.write('r1', testNow.add(const Duration(days: 10)));
      final refresh = Completer<FakeResponse>();
      api.on('POST', '/auth/refresh', (_) => refresh.future);

      await pumpApp(t, api: api, store: store, initialLocation: '/home');
      expect(currentLocation(t), '/loading?to=%2Fhome');
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      refresh.complete(FakeResponse.json(200, tokenJson(now: testNow)));
      await settleAuth(t);
      expect(currentLocation(t), '/home');
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('unreachable start shows retry; retry recovers', (t) async {
      final api = FakeApi();
      final store = MemoryTokenStore();
      await store.write('r1', testNow.add(const Duration(days: 10)));
      api.on('POST', '/auth/refresh', (_) => FakeResponse.networkError());

      await pumpApp(t, api: api, store: store, initialLocation: '/home');
      expect(currentLocation(t), '/loading?to=%2Fhome');
      expect(find.text("Can't reach the server"), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      api.on(
        'POST',
        '/auth/refresh',
        (_) => FakeResponse.json(200, tokenJson(now: testNow)),
      );
      await t.tap(find.text('Retry'));
      await t.pumpAndSettle();
      expect(currentLocation(t), '/home');
      expect(api.count('POST', '/auth/refresh'), 2);
    });
  });

  testWidgets('language switch changes the login title and back', (t) async {
    await pumpApp(t, initialLocation: '/login');
    expect(find.text('Sign in'), findsNWidgets(2));

    await t.tap(find.text('RO'));
    await t.pumpAndSettle();
    expect(find.text('Sign in'), findsNothing);
    expect(find.text('Conectează-te'), findsNWidgets(2));

    await t.tap(find.text('EN'));
    await t.pumpAndSettle();
    expect(find.text('Sign in'), findsNWidgets(2));
  });

  group('safeFrom', () {
    test('accepts in-app paths', () {
      expect(safeFrom('/home'), '/home');
      expect(safeFrom('/join/abc?x=1'), '/join/abc?x=1');
    });

    test('rejects anything else', () {
      for (final bad in [
        null,
        '',
        'home',
        '//evil.com',
        '/\\evil.com',
        'https://evil.com',
        'javascript:alert(1)',
      ]) {
        expect(safeFrom(bad), isNull, reason: '$bad');
      }
    });
  });
}
