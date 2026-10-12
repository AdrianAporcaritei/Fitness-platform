import 'dart:ui';

import 'package:ana_fit_lab/core/locale/locale_controller.dart';
import 'package:ana_fit_lab/core/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> make({
  Map<String, Object> saved = const {},
  required Locale browser,
}) async {
  SharedPreferences.setMockInitialValues(saved);
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      browserLocaleProvider.overrideWithValue(browser),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('saved ro wins over browser en-US', () async {
    final c = await make(
      saved: {'locale': 'ro'},
      browser: const Locale('en', 'US'),
    );
    expect(c.read(localeControllerProvider), const Locale('ro'));
  });

  test('browser ro-RO -> ro', () async {
    final c = await make(browser: const Locale('ro', 'RO'));
    expect(c.read(localeControllerProvider), const Locale('ro'));
  });

  test('browser de-DE -> en', () async {
    final c = await make(browser: const Locale('de', 'DE'));
    expect(c.read(localeControllerProvider), const Locale('en'));
  });

  test('invalid saved value falls back to browser rule', () async {
    final c = await make(saved: {'locale': 'fr'}, browser: const Locale('ro'));
    expect(c.read(localeControllerProvider), const Locale('ro'));
  });

  test('select persists', () async {
    final c = await make(browser: const Locale('en'));
    c.read(localeControllerProvider.notifier).select('ro');
    expect(c.read(localeControllerProvider), const Locale('ro'));
    expect(c.read(sharedPreferencesProvider).getString('locale'), 'ro');
  });

  test(
    'applyUserLocale overrides and saves; invalid ignored to browser rule',
    () async {
      final c = await make(browser: const Locale('en'));
      final n = c.read(localeControllerProvider.notifier);
      n.select('ro');
      n.applyUserLocale('en');
      expect(c.read(localeControllerProvider), const Locale('en'));
      expect(c.read(sharedPreferencesProvider).getString('locale'), 'en');
      n.applyUserLocale('xx');
      expect(c.read(localeControllerProvider), const Locale('en'));
    },
  );
}
