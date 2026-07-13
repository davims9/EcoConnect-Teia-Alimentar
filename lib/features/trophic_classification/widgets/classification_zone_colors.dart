import 'package:flutter/material.dart';
import '../models/trophic_level.dart';

/// UI colours, labels and icons per trophic zone.
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

  static Color colorOf(TrophicLevel level) =>
      _colors[level] ?? Colors.grey;

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

  /// Abbreviated label for narrow layouts.
  static String shortLabelOf(TrophicLevel level) {
    switch (level) {
      case TrophicLevel.producer:
        return 'Prod.';
      case TrophicLevel.primaryConsumer:
        return 'Cons. Prim.';
      case TrophicLevel.secondaryConsumer:
        return 'Cons. Sec.';
      case TrophicLevel.tertiaryConsumer:
        return 'Cons. Terc.';
    }
  }
}
