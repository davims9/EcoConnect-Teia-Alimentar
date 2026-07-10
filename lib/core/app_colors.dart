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
  static const Color connectionError = Color(0xFFE6553A);
  static const Color connectionErrorGlow = Color(0xFFFF8A65);
  static const Color organismBorder = Color(0xFF191C1B);

  static const List<Color> connectionColors = [
    Color(0xFF0072B2), // Azul
    Color(0xFF009E73), // Verde
    Color(0xFFF0E442), // Amarelo
    Color(0xFF56B4E9), // Azul-claro
    Color(0xFFE69F00), // Laranja
    Color(0xFFCC79A7), // Magenta
    Color(0xFF332288), // Azul-escuro
    Color(0xFF44AA99), // Turquesa
    Color(0xFF88CCEE), // Ciano-claro
    Color(0xFF117733), // Verde-escuro
    Color(0xFF999933), // Oliva
    Color(0xFFAA4499), // Roxo
  ];

  static int _connectionColorIndex = 0;

  static Color nextConnectionColor() {
    final color = connectionColors[_connectionColorIndex];
    _connectionColorIndex = (_connectionColorIndex + 1) % connectionColors.length;
    return color;
  }

  static void resetConnectionColorIndex() {
    _connectionColorIndex = 0;
  }
}
