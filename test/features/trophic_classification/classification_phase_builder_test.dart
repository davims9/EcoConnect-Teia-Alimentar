import 'package:flutter_test/flutter_test.dart';
import 'package:food_web_builder/features/trophic_classification/models/classification_hint.dart';
import 'package:food_web_builder/features/trophic_classification/models/trophic_level.dart';
import 'package:food_web_builder/features/trophic_classification/services/classification_phase_builder.dart';

void main() {
  final builder = ClassificationPhaseBuilder();

  group('ClassificationPhaseBuilder.buildCampo', () {
    final config = builder.buildCampo();

    test('returns correct key and biome', () {
      expect(config.key, equals('classification_field_01'));
      expect(config.biomePhaseId, equals(1));
      expect(config.biomeName, equals('Campo'));
    });

    test('contains exactly 7 organisms', () {
      expect(config.totalOrganisms, equals(7));
      expect(config.organisms.length, equals(7));
    });

    test('has learning messages', () {
      expect(config.learningMessages, isNotEmpty);
    });

    test('Capim (id 1) is producer, not top predator', () {
      final capim = config.organisms.firstWhere((o) => o.organismId == 1);
      expect(capim.expectedLevel, equals(TrophicLevel.producer));
      expect(capim.isTopPredator, isFalse);
      expect(capim.justification, isNotEmpty);
      expect(capim.hintMessages.length, equals(3));
    });

    test('Gafanhoto (id 2) is primary consumer', () {
      final gafanhoto = config.organisms.firstWhere((o) => o.organismId == 2);
      expect(gafanhoto.expectedLevel, equals(TrophicLevel.primaryConsumer));
      expect(gafanhoto.isTopPredator, isFalse);
    });

    test('Coelho (id 3) is primary consumer', () {
      final coelho = config.organisms.firstWhere((o) => o.organismId == 3);
      expect(coelho.expectedLevel, equals(TrophicLevel.primaryConsumer));
      expect(coelho.isTopPredator, isFalse);
    });

    test('Sapo (id 4) is secondary consumer', () {
      final sapo = config.organisms.firstWhere((o) => o.organismId == 4);
      expect(sapo.expectedLevel, equals(TrophicLevel.secondaryConsumer));
      expect(sapo.isTopPredator, isFalse);
    });

    test('Cobra (id 5) is tertiary consumer with contextual justification', () {
      final cobra = config.organisms.firstWhere((o) => o.organismId == 5);
      expect(cobra.expectedLevel, equals(TrophicLevel.tertiaryConsumer));
      expect(cobra.isTopPredator, isFalse);
      expect(cobra.justification, contains('contextual'));
    });

    test('Raposa (id 6) is tertiary consumer + top predator', () {
      final raposa = config.organisms.firstWhere((o) => o.organismId == 6);
      expect(raposa.expectedLevel, equals(TrophicLevel.tertiaryConsumer));
      expect(raposa.isTopPredator, isTrue);
    });

    test('Águia (id 7) is tertiary consumer + top predator', () {
      final aguia = config.organisms.firstWhere((o) => o.organismId == 7);
      expect(aguia.expectedLevel, equals(TrophicLevel.tertiaryConsumer));
      expect(aguia.isTopPredator, isTrue);
    });

    test('every organism has 3 hint messages', () {
      for (final org in config.organisms) {
        expect(
          org.hintMessages.length,
          equals(3),
          reason: 'Organism ${org.organismId} should have 3 hints',
        );
      }
    });

    test('every organism has non-empty justification', () {
      for (final org in config.organisms) {
        expect(
          org.justification,
          isNotEmpty,
          reason: 'Organism ${org.organismId} should have justification',
        );
      }
    });
  });

  group('ClassificationPhaseBuilder.buildFloresta', () {
    final config = builder.buildFloresta();

    test('returns correct key and biome', () {
      expect(config.key, equals('classification_forest_01'));
      expect(config.biomePhaseId, equals(2));
      expect(config.biomeName, equals('Floresta'));
    });

    test('contains exactly 8 organisms', () {
      expect(config.totalOrganisms, equals(8));
      expect(config.organisms.length, equals(8));
    });

    test('has learning messages', () {
      expect(config.learningMessages, isNotEmpty);
    });

    test('Arbusto (id 8) is producer', () {
      final org = config.organisms.firstWhere((o) => o.organismId == 8);
      expect(org.expectedLevel, equals(TrophicLevel.producer));
      expect(org.isTopPredator, isFalse);
    });

    test('Lagarta (id 9) is primary consumer', () {
      final org = config.organisms.firstWhere((o) => o.organismId == 9);
      expect(org.expectedLevel, equals(TrophicLevel.primaryConsumer));
      expect(org.isTopPredator, isFalse);
    });

    test('Veado (id 14) is primary consumer', () {
      final org = config.organisms.firstWhere((o) => o.organismId == 14);
      expect(org.expectedLevel, equals(TrophicLevel.primaryConsumer));
      expect(org.isTopPredator, isFalse);
    });

    test('Aranha (id 10) is secondary consumer', () {
      final org = config.organisms.firstWhere((o) => o.organismId == 10);
      expect(org.expectedLevel, equals(TrophicLevel.secondaryConsumer));
      expect(org.isTopPredator, isFalse);
    });

    test('Sapo (id 11) is secondary consumer', () {
      final org = config.organisms.firstWhere((o) => o.organismId == 11);
      expect(org.expectedLevel, equals(TrophicLevel.secondaryConsumer));
      expect(org.isTopPredator, isFalse);
    });

    test('Cobra (id 12) is tertiary consumer', () {
      final org = config.organisms.firstWhere((o) => o.organismId == 12);
      expect(org.expectedLevel, equals(TrophicLevel.tertiaryConsumer));
      expect(org.isTopPredator, isFalse);
    });

    test('Gavião (id 13) is tertiary consumer + top predator', () {
      final org = config.organisms.firstWhere((o) => o.organismId == 13);
      expect(org.expectedLevel, equals(TrophicLevel.tertiaryConsumer));
      expect(org.isTopPredator, isTrue);
    });

    test('Onça-pintada (id 15) is tertiary consumer + top predator', () {
      final org = config.organisms.firstWhere((o) => o.organismId == 15);
      expect(org.expectedLevel, equals(TrophicLevel.tertiaryConsumer));
      expect(org.isTopPredator, isTrue);
    });

    test('every organism has 3 hint messages', () {
      for (final org in config.organisms) {
        expect(
          org.hintMessages.length,
          equals(3),
          reason: 'Organism ${org.organismId} should have 3 hints',
        );
      }
    });

    test('every organism has non-empty justification', () {
      for (final org in config.organisms) {
        expect(
          org.justification,
          isNotEmpty,
          reason: 'Organism ${org.organismId} should have justification',
        );
      }
    });
  });

  group('ClassificationPhaseBuilder.buildOceano', () {
    final config = builder.buildOceano();

    test('returns correct key and biome', () {
      expect(config.key, equals('classification_ocean_01'));
      expect(config.biomePhaseId, equals(3));
      expect(config.biomeName, equals('Oceano'));
    });

    test('contains exactly 7 organisms', () {
      expect(config.totalOrganisms, equals(7));
      expect(config.organisms.length, equals(7));
    });

    test('has learning messages', () {
      expect(config.learningMessages, isNotEmpty);
    });

    test('Fitoplâncton (id 16) is producer', () {
      final org = config.organisms.firstWhere((o) => o.organismId == 16);
      expect(org.expectedLevel, equals(TrophicLevel.producer));
      expect(org.isTopPredator, isFalse);
    });

    test('Alga (id 17) is producer', () {
      final org = config.organisms.firstWhere((o) => o.organismId == 17);
      expect(org.expectedLevel, equals(TrophicLevel.producer));
      expect(org.isTopPredator, isFalse);
    });

    test('Camarão (id 18) is primary consumer', () {
      final org = config.organisms.firstWhere((o) => o.organismId == 18);
      expect(org.expectedLevel, equals(TrophicLevel.primaryConsumer));
      expect(org.isTopPredator, isFalse);
    });

    test('Sardinha (id 19) is secondary consumer', () {
      final org = config.organisms.firstWhere((o) => o.organismId == 19);
      expect(org.expectedLevel, equals(TrophicLevel.secondaryConsumer));
      expect(org.isTopPredator, isFalse);
    });

    test('Polvo (id 20) is tertiary consumer', () {
      final org = config.organisms.firstWhere((o) => o.organismId == 20);
      expect(org.expectedLevel, equals(TrophicLevel.tertiaryConsumer));
      expect(org.isTopPredator, isFalse);
    });

    test('Atum (id 21) is tertiary consumer', () {
      final org = config.organisms.firstWhere((o) => o.organismId == 21);
      expect(org.expectedLevel, equals(TrophicLevel.tertiaryConsumer));
      expect(org.isTopPredator, isFalse);
    });

    test('Tubarão (id 22) is tertiary consumer + top predator', () {
      final org = config.organisms.firstWhere((o) => o.organismId == 22);
      expect(org.expectedLevel, equals(TrophicLevel.tertiaryConsumer));
      expect(org.isTopPredator, isTrue);
    });

    test('every organism has 3 hint messages', () {
      for (final org in config.organisms) {
        expect(
          org.hintMessages.length,
          equals(3),
          reason: 'Organism ${org.organismId} should have 3 hints',
        );
      }
    });

    test('every organism has non-empty justification', () {
      for (final org in config.organisms) {
        expect(
          org.justification,
          isNotEmpty,
          reason: 'Organism ${org.organismId} should have justification',
        );
      }
    });
  });

  group('ClassificationPhaseBuilder.buildPantanal', () {
    final config = builder.buildPantanal();

    test('returns correct key and biome', () {
      expect(config.key, equals('classification_pantanal_01'));
      expect(config.biomePhaseId, equals(4));
      expect(config.biomeName, equals('Pantanal'));
    });

    test('contains exactly 7 organisms', () {
      expect(config.totalOrganisms, equals(7));
      expect(config.organisms.length, equals(7));
    });

    test('has learning messages', () {
      expect(config.learningMessages, isNotEmpty);
    });

    test('Planta aquática (id 23) is producer', () {
      final org = config.organisms.firstWhere((o) => o.organismId == 23);
      expect(org.expectedLevel, equals(TrophicLevel.producer));
      expect(org.isTopPredator, isFalse);
    });

    test('Caramujo (id 24) is primary consumer', () {
      final org = config.organisms.firstWhere((o) => o.organismId == 24);
      expect(org.expectedLevel, equals(TrophicLevel.primaryConsumer));
      expect(org.isTopPredator, isFalse);
    });

    test('Peixe (id 25) is secondary consumer', () {
      final org = config.organisms.firstWhere((o) => o.organismId == 25);
      expect(org.expectedLevel, equals(TrophicLevel.secondaryConsumer));
      expect(org.isTopPredator, isFalse);
    });

    test('Garça (id 26) is tertiary consumer', () {
      final org = config.organisms.firstWhere((o) => o.organismId == 26);
      expect(org.expectedLevel, equals(TrophicLevel.tertiaryConsumer));
      expect(org.isTopPredator, isFalse);
    });

    test('Jacaré (id 27) is tertiary consumer', () {
      final org = config.organisms.firstWhere((o) => o.organismId == 27);
      expect(org.expectedLevel, equals(TrophicLevel.tertiaryConsumer));
      expect(org.isTopPredator, isFalse);
    });

    test('Cobra sucuri (id 28) is tertiary consumer + top predator', () {
      final org = config.organisms.firstWhere((o) => o.organismId == 28);
      expect(org.expectedLevel, equals(TrophicLevel.tertiaryConsumer));
      expect(org.isTopPredator, isTrue);
    });

    test('Onça-pintada (id 29) is tertiary consumer + top predator', () {
      final org = config.organisms.firstWhere((o) => o.organismId == 29);
      expect(org.expectedLevel, equals(TrophicLevel.tertiaryConsumer));
      expect(org.isTopPredator, isTrue);
    });

    test('every organism has 3 hint messages', () {
      for (final org in config.organisms) {
        expect(
          org.hintMessages.length,
          equals(3),
          reason: 'Organism ${org.organismId} should have 3 hints',
        );
      }
    });

    test('every organism has non-empty justification', () {
      for (final org in config.organisms) {
        expect(
          org.justification,
          isNotEmpty,
          reason: 'Organism ${org.organismId} should have justification',
        );
      }
    });
  });

  group('HintLevel enum', () {
    test('has exactly 3 values', () {
      expect(HintLevel.values.length, equals(3));
    });

    test('values are in correct order', () {
      expect(HintLevel.values[0], equals(HintLevel.conceptual));
      expect(HintLevel.values[1], equals(HintLevel.relational));
      expect(HintLevel.values[2], equals(HintLevel.directional));
    });
  });
}
