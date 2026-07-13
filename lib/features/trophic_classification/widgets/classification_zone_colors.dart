import 'package:flutter/material.dart';
import '../models/trophic_level.dart';

/// UI colours, labels, level numbers and descriptions per trophic zone.
///
/// Defined in the UI layer, not in domain models — avoids coupling
/// TrophicLevel to any visual representation.
class ClassificationZoneColors {
  ClassificationZoneColors._();

  static const Map<TrophicLevel, Color> _colors = {
    TrophicLevel.producer: Color(0xFF2E7D32),
    TrophicLevel.primaryConsumer: Color(0xFFFBBF24),
    TrophicLevel.secondaryConsumer: Color(0xFFF97316),
    TrophicLevel.tertiaryConsumer: Color(0xFF8B5CF6),
  };

  static Color colorOf(TrophicLevel level) => _colors[level] ?? Colors.grey;

  /// Full category name (never abbreviated — content for children).
  static String labelOf(TrophicLevel level) {
    switch (level) {
      case TrophicLevel.producer:
        return 'Produtores';
      case TrophicLevel.primaryConsumer:
        return 'Consumidores Primários';
      case TrophicLevel.secondaryConsumer:
        return 'Consumidores Secundários';
      case TrophicLevel.tertiaryConsumer:
        return 'Consumidores Terciários';
    }
  }

  static IconData iconOf(TrophicLevel level) {
    switch (level) {
      case TrophicLevel.producer:
        return Icons.eco;
      case TrophicLevel.primaryConsumer:
        return Icons.cruelty_free;
      case TrophicLevel.secondaryConsumer:
        return Icons.local_fire_department;
      case TrophicLevel.tertiaryConsumer:
        return Icons.shield;
    }
  }

  /// Trophic level number for display (1 = base / producers).
  static String levelNumberOf(TrophicLevel level) {
    switch (level) {
      case TrophicLevel.producer:
        return '1\u00BA';
      case TrophicLevel.primaryConsumer:
        return '2\u00BA';
      case TrophicLevel.secondaryConsumer:
        return '3\u00BA';
      case TrophicLevel.tertiaryConsumer:
        return '4\u00BA';
    }
  }

  /// Short pedagogical description for the zone.
  static String descriptionOf(TrophicLevel level) {
    switch (level) {
      case TrophicLevel.producer:
        return 'Produzem seu pr\u00F3prio alimento';
      case TrophicLevel.primaryConsumer:
        return 'Alimentam-se dos produtores';
      case TrophicLevel.secondaryConsumer:
        return 'Alimentam-se dos consumidores prim\u00E1rios';
      case TrophicLevel.tertiaryConsumer:
        return 'Topo da cadeia alimentar';
    }
  }
}
