import 'dart:ui';

import 'package:ana_fit_lab/app.dart';
import 'package:ana_fit_lab/core/auth/auth_controller.dart';
import 'package:ana_fit_lab/core/auth/token_store.dart';
import 'package:ana_fit_lab/core/routing/router.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_container.dart';
import 'fake_api.dart';

/// Pumps the real [App] (router, theme, l10n) on the [testOverrides] seams,
/// opened at [initialLocation] as if typed in the address bar. Returns once
/// the launch `start()` has settled; while it is still pending (e.g. a
/// refresh held by a `Completer`), returns with the splash shown.
Future<void> pumpApp(
  WidgetTester t, {
  FakeApi? api,
  TokenStore? store,
  String initialLocation = '/',
  Map<String, Object> prefs = const {},
  Locale browserLocale = const Locale('en'),
}) async {
  t.view.physicalSize = const Size(1280, 900);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  t.binding.platformDispatcher.defaultRouteNameTestValue = initialLocation;
  addTearDown(t.binding.platformDispatcher.clearDefaultRouteNameTestValue);

  final overrides = await testOverrides(
    api: api ?? FakeApi(),
    store: store,
    prefs: prefs,
    browser: browserLocale,
  );
  await t.pumpWidget(ProviderScope(overrides: overrides, child: const App()));
  await settleAuth(t);
}

/// Pumps until the auth state is resolved (or `start()` is still pending
/// after a bounded number of frames), then lets navigation finish.
Future<void> settleAuth(WidgetTester t) async {
  final container = appContainer(t);
  // Some async steps of a request sit behind short timers, so let (fake)
  // time pass: at most 1 s, far below Dio's timeouts.
  for (var i = 0; i < 20; i++) {
    if (container.read(authControllerProvider) != const AuthUnknown()) break;
    await t.pump(const Duration(milliseconds: 50));
  }
  if (container.read(authControllerProvider) == const AuthUnknown()) {
    // Splash spinner animates forever: pumpAndSettle would never return.
    await t.pump();
  } else {
    await t.pumpAndSettle();
  }
}

ProviderContainer appContainer(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(App)));

/// The router's current location, e.g. `/login?from=%2Fhome`.
String currentLocation(WidgetTester t) =>
    appContainer(t)
        .read(routerProvider)
        .routerDelegate
        .currentConfiguration
        .uri
        .toString();
