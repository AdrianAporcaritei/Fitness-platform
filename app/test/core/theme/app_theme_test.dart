import 'package:ana_fit_lab/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildAppTheme is a dark Poppins theme using the design tokens', () {
    final theme = buildAppTheme();

    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, const Color(0xFF0E0E0F));
    expect(theme.colorScheme.primary, const Color(0xFFFB923C));
    expect(theme.colorScheme.onPrimary, const Color(0xFF1F0D02));
    expect(theme.colorScheme.error, const Color(0xFFFF8A80));
    expect(theme.textTheme.bodyMedium!.fontFamily, 'Poppins');
  });
}
