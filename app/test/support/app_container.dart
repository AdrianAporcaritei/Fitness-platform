import 'dart:ui';

import 'package:ana_fit_lab/core/api/api_client.dart';
import 'package:ana_fit_lab/core/auth/token_store.dart';
import 'package:ana_fit_lab/core/auth/web_lock.dart';
import 'package:ana_fit_lab/core/locale/locale_controller.dart';
import 'package:ana_fit_lab/core/storage.dart';
import 'package:ana_fit_lab/core/time.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_api.dart';

/// Fixed "now" used by tests unless they pass their own clock.
final testNow = DateTime.utc(2026, 10, 11, 12);

/// Overrides every platform/time/HTTP seam of the session core. Shared by
/// [makeContainer] and `pumpApp` so both run on the same seams.
Future<List<Override>> testOverrides({
  required FakeApi api,
  TokenStore? store,
  DateTime Function()? now,
  Map<String, Object> prefs = const {},
  Locale browser = const Locale('en'),
  List<Override> overrides = const [],
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sharedPrefs = await SharedPreferences.getInstance();
  return [
    sharedPreferencesProvider.overrideWithValue(sharedPrefs),
    browserLocaleProvider.overrideWithValue(browser),
    tokenStoreProvider.overrideWithValue(store ?? MemoryTokenStore()),
    crossTabLockProvider.overrideWithValue(InProcessLock()),
    nowProvider.overrideWithValue(now ?? () => testNow),
    httpAdapterProvider.overrideWithValue(api),
    ...overrides,
  ];
}

/// A container on [testOverrides]. Construct [api] inside the test body
/// (FakeApi registers its own teardown check).
Future<ProviderContainer> makeContainer({
  required FakeApi api,
  TokenStore? store,
  DateTime Function()? now,
  Map<String, Object> prefs = const {},
  Locale browser = const Locale('en'),
  List<Override> overrides = const [],
}) async {
  final container = ProviderContainer(
    overrides: await testOverrides(
      api: api,
      store: store,
      now: now,
      prefs: prefs,
      browser: browser,
      overrides: overrides,
    ),
  );
  addTearDown(container.dispose);
  return container;
}
