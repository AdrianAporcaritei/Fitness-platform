import 'package:flutter/material.dart';

/// Design tokens (spec section 11). Pages read colors from here or from `Theme`.
abstract final class AppTokens {
  static const Color background = Color(0xFF0E0E0F);
  static const Color surface = Color(0xFF141415);
  static const Color surface2 = Color(0xFF18181A);
  static const Color surface3 = Color(0xFF222224);
  static const Color border = Color(0xFF262628);
  static const Color borderStrong = Color(0xFF2A2A2C);
  static const Color text = Color(0xFFF2F2F3);
  static const Color textMuted = Color(0xFFA1A1A6);
  static const Color textSubtle = Color(0xFF8A8A8F);
  static const Color accent = Color(0xFFFB923C);
  static const Color accentHover = Color(0xFFFDAB6D);
  static const Color onAccent = Color(0xFF1F0D02);
  static const Color errorText = Color(0xFFFF8A80);
  static const Color errorSurface = Color(0xFF2A1215);
  static const Color errorBorder = Color(0xFF5C2B2E);

  static const double radius = 12;
  static const double radiusSmall = 8;
}
