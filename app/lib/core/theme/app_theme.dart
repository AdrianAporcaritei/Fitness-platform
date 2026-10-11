import 'package:flutter/material.dart';

import 'tokens.dart';

ThemeData buildAppTheme() {
  final shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppTokens.radius),
  );
  OutlineInputBorder outline(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radius),
        borderSide: BorderSide(color: color),
      );

  final scheme = const ColorScheme.dark().copyWith(
    primary: AppTokens.accent,
    onPrimary: AppTokens.onAccent,
    secondary: AppTokens.accentHover,
    onSecondary: AppTokens.onAccent,
    error: AppTokens.errorText,
    onError: AppTokens.onAccent,
    errorContainer: AppTokens.errorSurface,
    onErrorContainer: AppTokens.errorText,
    surface: AppTokens.surface,
    onSurface: AppTokens.text,
    onSurfaceVariant: AppTokens.textMuted,
    surfaceContainerLowest: AppTokens.background,
    surfaceContainerLow: AppTokens.surface,
    surfaceContainer: AppTokens.surface2,
    surfaceContainerHigh: AppTokens.surface3,
    surfaceContainerHighest: AppTokens.surface3,
    outline: AppTokens.borderStrong,
    outlineVariant: AppTokens.border,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
    colorScheme: scheme,
    scaffoldBackgroundColor: AppTokens.background,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: 'Poppins',
      bodyColor: AppTokens.text,
      displayColor: AppTokens.text,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppTokens.surface2,
      labelStyle: const TextStyle(color: AppTokens.textMuted),
      hintStyle: const TextStyle(color: AppTokens.textSubtle),
      errorStyle: const TextStyle(color: AppTokens.errorText),
      border: outline(AppTokens.border),
      enabledBorder: outline(AppTokens.border),
      focusedBorder: outline(AppTokens.accent),
      errorBorder: outline(AppTokens.errorBorder),
      focusedErrorBorder: outline(AppTokens.errorText),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppTokens.accent,
        foregroundColor: AppTokens.onAccent,
        minimumSize: const Size.fromHeight(48),
        shape: shape,
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppTokens.accent),
    ),
  );
}
