import 'package:ana_fit_lab/core/l10n/app_localizations.dart';
import 'package:ana_fit_lab/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_container.dart';
import 'fake_api.dart';

/// Pumps a single widget with the app theme, English l10n and the test
/// provider seams (no router).
Future<void> pumpWidgetInApp(
  WidgetTester t,
  Widget child, {
  Size size = const Size(1280, 900),
}) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final overrides = await testOverrides(api: FakeApi());
  await t.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: buildAppTheme(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    ),
  );
  await t.pump();
}
