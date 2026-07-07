import 'dart:math';

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Ecosystem Weaver palette
  static const Color primary = Color(0xFF0C601C);
  static const Color primaryLight = Color(0xFF2D7A32);
  static const Color primaryDark = Color(0xFF005313);
  static const Color primaryContainer = Color(0xFFA4F69E);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color secondary = Color(0xFF79573F);
  static const Color secondaryLight = Color(0xFFEABDA0);
  static const Color secondaryDark = Color(0xFF5F402A);
  static const Color secondaryContainer = Color(0xFFFFDCC6);
  static const Color onSecondary = Color(0xFFFFFFFF);

  static const Color tertiary = Color(0xFF325B46);
  static const Color tertiaryContainer = Color(0xFFBFEDD1);
  static const Color onTertiary = Color(0xFFFFFFFF);

  static const Color surface = Color(0xFFF8FAF8);
  static const Color surfaceDim = Color(0xFFD8DAD9);
  static const Color surfaceBright = Color(0xFFF8FAF8);
  static const Color surfaceContainerLow = Color(0xFFF2F4F2);
  static const Color surfaceContainer = Color(0xFFECEEEC);
  static const Color surfaceContainerHigh = Color(0xFFE6E9E7);

  static const Color background = Color(0xFFF8FAF8);
  static const Color onBackground = Color(0xFF191C1B);

  static const Color onSurface = Color(0xFF191C1B);
  static const Color onSurfaceVariant = Color(0xFF40493D);

  static const Color outline = Color(0xFF707A6C);
  static const Color outlineVariant = Color(0xFFC0C9BA);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);

  static const Color correct = Color(0xFF4CAF50);
  static const Color hint = Color(0xFFFFC107);

  static const Color textPrimary = Color(0xFF191C1B);
  static const Color textSecondary = Color(0xFF40493D);

  static const Color connectionLine = Color(0xFF4CAF50);
  static const Color connectionLineHover = Color(0xFF81C784);
  static const Color connectionError = Color(0xFFEF5350);
  static const Color organismBorder = Color(0xFF191C1B);

  static final Random _random = Random();

  /// Returns a random vibrant, light color excluding red tones.
  static Color randomConnectionColor() {
    double hue;
    do {
      hue = _random.nextDouble() * 360;
    } while (hue < 30 || hue > 340);

    final saturation = 0.6 + _random.nextDouble() * 0.4;
    final lightness = 0.55 + _random.nextDouble() * 0.25;

    return HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
  }
}
