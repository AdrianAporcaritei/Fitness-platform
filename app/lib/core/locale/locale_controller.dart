import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage.dart';

const _prefsKey = 'locale';
const _supported = {'en', 'ro'};

final browserLocaleProvider = Provider<Locale>(
  (_) => PlatformDispatcher.instance.locale,
);

/// Active UI language: saved choice, else browser language (`ro` or `en`).
class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    final saved = ref.read(sharedPreferencesProvider).getString(_prefsKey);
    if (saved != null && _supported.contains(saved)) return Locale(saved);
    return _fromBrowser();
  }

  Locale _fromBrowser() {
    final code = ref.read(browserLocaleProvider).languageCode;
    return Locale(code == 'ro' ? 'ro' : 'en');
  }

  /// User picked a language: apply and remember.
  void select(String languageCode) => _set(languageCode);

  /// Server-side preference of the signed-in user: apply and remember.
  void applyUserLocale(String languageCode) => _set(languageCode);

  void _set(String languageCode) {
    if (!_supported.contains(languageCode)) {
      state = _fromBrowser();
      return;
    }
    state = Locale(languageCode);
    ref.read(sharedPreferencesProvider).setString(_prefsKey, languageCode);
  }
}

final localeControllerProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);
