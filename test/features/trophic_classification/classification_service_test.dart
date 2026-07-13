import 'package:flutter_test/flutter_test.dart';
import 'package:food_web_builder/features/trophic_classification/services/classification_phase_builder.dart';
import 'package:food_web_builder/features/trophic_classification/services/classification_service.dart';
import 'package:food_web_builder/features/trophic_classification/models/classification_card_status.dart';
import 'package:food_web_builder/features/trophic_classification/models/classification_hint.dart';
import 'package:food_web_builder/features/trophic_classification/models/trophic_level.dart';

void main() {
  late ClassificationService service;

  setUp(() {
    service = ClassificationService();
    final builder = ClassificationPhaseBuilder();
    service.loadPhase(builder.buildCampo());
  });

  group('loadPhase', () {
    test('loads config and sets all cards to shelf', () {
      expect(service.hasConfig, isTrue);
      expect(service.totalOrganisms, equals(7));
      expect(service.placedCount, equals(0));
      expect(service.canVerify, isFalse);
      expect(service.isComplete, isFalse);
      expect(service.correctCount, equals(0));
      expect(service.lastResult, isNull);
    });

    test('all organisms start in shelf status', () {
      for (final org in service.config!.organisms) {
        expect(
          service.statusOf(org.organismId),
          equals(ClassificationCardStatus.shelf),
        );
        expect(service.placementOf(org.organismId), isNull);
      }
    });

    test('loading again resets all state', () {
      // Place all cards
      for (final org in service.config!.organisms) {
        service.placeCard(org.organismId, org.expectedLevel);
      }
      service.verify();
      expect(service.isComplete, isTrue);

      // Reload same config
      final builder = ClassificationPhaseBuilder();
      service.loadPhase(builder.buildCampo());

      expect(service.placedCount, equals(0));
      expect(service.canVerify, isFalse);
      expect(service.isComplete, isFalse);
      expect(service.correctCount, equals(0));
      expect(service.lastResult, isNull);
    });
  });

  group('placeCard', () {
    test('places a card in a zone', () {
      service.placeCard(1, TrophicLevel.producer);

      expect(service.statusOf(1), equals(ClassificationCardStatus.placed));
      expect(service.placementOf(1), equals(TrophicLevel.producer));
      expect(service.placedCount, equals(1));
    });

    test('moves a card between zones', () {
      service.placeCard(1, TrophicLevel.producer);
      service.placeCard(1, TrophicLevel.primaryConsumer);

      expect(service.placementOf(1), equals(TrophicLevel.primaryConsumer));
      expect(service.placedCount, equals(1));
    });

    test('placing a locked correct card is no-op', () {
      // Lock card 1 (correct placement)
      service.placeCard(1, TrophicLevel.producer); // Capim = producer ✓
      service.placeCard(2, TrophicLevel.primaryConsumer); // Gafanhoto ✓
      service.placeCard(3, TrophicLevel.primaryConsumer);
      service.placeCard(4, TrophicLevel.secondaryConsumer);
      service.placeCard(5, TrophicLevel.tertiaryConsumer);
      service.placeCard(6, TrophicLevel.tertiaryConsumer);
      service.placeCard(7, TrophicLevel.tertiaryConsumer);
      service.verify();

      expect(
        service.statusOf(1),
        equals(ClassificationCardStatus.lockedCorrect),
      );

      // Try to move it
      service.placeCard(1, TrophicLevel.tertiaryConsumer);
      expect(service.placementOf(1), equals(TrophicLevel.producer));
    });
  });

  group('returnCardToShelf', () {
    test('returns a placed card to shelf', () {
      service.placeCard(1, TrophicLevel.producer);
      service.returnCardToShelf(1);

      expect(service.statusOf(1), equals(ClassificationCardStatus.shelf));
      expect(service.placementOf(1), isNull);
      expect(service.placedCount, equals(0));
    });

    test('shelf card return is no-op', () {
      service.returnCardToShelf(1);
      expect(service.placedCount, equals(0));
    });

    test('locked correct card return is no-op', () {
      // Place and lock correctly
      service.placeCard(1, TrophicLevel.producer);
      service.placeCard(2, TrophicLevel.primaryConsumer);
      service.placeCard(3, TrophicLevel.primaryConsumer);
      service.placeCard(4, TrophicLevel.secondaryConsumer);
      service.placeCard(5, TrophicLevel.tertiaryConsumer);
      service.placeCard(6, TrophicLevel.tertiaryConsumer);
      service.placeCard(7, TrophicLevel.tertiaryConsumer);
      service.verify();

      service.returnCardToShelf(1);
      expect(
        service.statusOf(1),
        equals(ClassificationCardStatus.lockedCorrect),
      );
      expect(service.placementOf(1), equals(TrophicLevel.producer));
    });
  });

  group('canVerify', () {
    test('false when no cards placed', () {
      expect(service.canVerify, isFalse);
    });

    test('false when some cards placed', () {
      service.placeCard(1, TrophicLevel.producer);
      service.placeCard(2, TrophicLevel.primaryConsumer);
      expect(service.canVerify, isFalse);
    });

    test('true when all cards placed', () {
      _placeAllCorrectly(service);
      expect(service.canVerify, isTrue);
    });

    test('false when phase is complete', () {
      _placeAllCorrectly(service);
      service.verify();
      expect(service.canVerify, isFalse);
    });
  });

  group('verify — all correct on first try', () {
    test('locks all cards and completes phase', () {
      _placeAllCorrectly(service);
      final result = service.verify();

      expect(result.isComplete, isTrue);
      expect(result.correctIds.length, equals(7));
      expect(result.incorrectIds, isEmpty);
      expect(service.isComplete, isTrue);
      expect(service.correctCount, equals(7));

      // All should be locked correct
      for (final org in service.config!.organisms) {
        expect(
          service.statusOf(org.organismId),
          equals(ClassificationCardStatus.lockedCorrect),
        );
      }
    });

    test('score is max (700) and stars 3', () {
      _placeAllCorrectly(service);
      service.verify();

      expect(service.score, equals(700));
      expect(service.stars, equals(3));
    });
  });

  group('verify — some incorrect', () {
    test('splits cards into correct and incorrect sets', () {
      service.placeCard(1, TrophicLevel.producer); // Capim → producer ✓
      service.placeCard(2, TrophicLevel.primaryConsumer); // Gafanhoto ✓
      service.placeCard(3, TrophicLevel.primaryConsumer); // Coelho ✓
      service.placeCard(
        4,
        TrophicLevel.tertiaryConsumer,
      ); // Sapo ✗ (should be secondary)
      service.placeCard(5, TrophicLevel.tertiaryConsumer); // Cobra ✓
      service.placeCard(6, TrophicLevel.tertiaryConsumer); // Raposa ✓
      service.placeCard(7, TrophicLevel.tertiaryConsumer); // Águia ✓

      final result = service.verify();

      expect(result.correctIds, containsAll({1, 2, 3, 5, 6, 7}));
      expect(result.incorrectIds, equals({4})); // Sapo is wrong
      expect(result.isComplete, isFalse);
      expect(service.isComplete, isFalse);

      // Correct cards are locked
      expect(
        service.statusOf(1),
        equals(ClassificationCardStatus.lockedCorrect),
      );
      expect(
        service.statusOf(2),
        equals(ClassificationCardStatus.lockedCorrect),
      );

      // Wrong card is verifiedIncorrect
      expect(
        service.statusOf(4),
        equals(ClassificationCardStatus.verifiedIncorrect),
      );
    });

    test('wrong placements tracked per organism', () {
      service.placeCard(1, TrophicLevel.producer); // ✓
      service.placeCard(2, TrophicLevel.primaryConsumer); // ✓
      service.placeCard(3, TrophicLevel.producer); // ✗ (should be primary)
      service.placeCard(4, TrophicLevel.secondaryConsumer); // ✓
      service.placeCard(5, TrophicLevel.tertiaryConsumer); // ✓
      service.placeCard(6, TrophicLevel.tertiaryConsumer); // ✓
      service.placeCard(7, TrophicLevel.tertiaryConsumer); // ✓

      service.verify();

      // Fix Coelho and verify again
      service.placeCard(3, TrophicLevel.primaryConsumer);
      service.verify();

      expect(service.isComplete, isTrue);
      // Coelho was wrong once → later try
      expect(service.score, equals(640)); // 6×100 + 1×50 - 1×10
    });
  });

  group('verify — retry after partial correct', () {
    test('partial correct, fix incorrect, all locked', () {
      // Place all, with Sapo wrong
      _placeAllCorrectly(service);
      service.placeCard(4, TrophicLevel.tertiaryConsumer); // Sapo wrong
      var result = service.verify();

      expect(result.isComplete, isFalse);
      expect(result.correctIds.length, equals(6));
      expect(result.incorrectIds, equals({4}));

      // Fix Sapo and re-verify
      service.placeCard(4, TrophicLevel.secondaryConsumer);
      result = service.verify();

      expect(result.isComplete, isTrue);
      expect(service.isComplete, isTrue);
      expect(service.correctCount, equals(7));

      // Check scoring: 6 first try + 1 later try - 1 wrong placement
      expect(service.score, equals(640)); // 6×100 + 1×50 - 1×10
      expect(service.stars, equals(3)); // 640/700 = 0.914... ≥ 0.85
    });

    test('third attempt after two partial verifies', () {
      // 1 wrong on first verify
      service.placeCard(1, TrophicLevel.producer);
      service.placeCard(2, TrophicLevel.primaryConsumer);
      service.placeCard(3, TrophicLevel.primaryConsumer);
      service.placeCard(4, TrophicLevel.tertiaryConsumer); // wrong
      service.placeCard(5, TrophicLevel.tertiaryConsumer);
      service.placeCard(6, TrophicLevel.tertiaryConsumer);
      service.placeCard(7, TrophicLevel.tertiaryConsumer);
      service.verify();

      // Still wrong on second verify
      service.placeCard(4, TrophicLevel.tertiaryConsumer); // still wrong
      service.verify();

      // 6 first try, wrong placements: 2 (Sapo wrong twice)
      expect(service.score, equals(580)); // 6×100 - 2×10 = 580
      // Sapo not yet correct

      // Fix on third verify
      service.placeCard(4, TrophicLevel.secondaryConsumer);
      service.verify();

      expect(service.isComplete, isTrue);
      // 6 first try + 1 later try - 2 wrong placements
      expect(service.score, equals(630)); // 6×100 + 1×50 - 2×10
    });

    test('locked correct cards are carried forward', () {
      _placeAllCorrectly(service);
      service.placeCard(4, TrophicLevel.tertiaryConsumer); // Sapo wrong
      service.verify();

      // Check locked cards stayed locked
      expect(
        service.statusOf(1),
        equals(ClassificationCardStatus.lockedCorrect),
      );
      expect(
        service.statusOf(2),
        equals(ClassificationCardStatus.lockedCorrect),
      );
      expect(
        service.statusOf(3),
        equals(ClassificationCardStatus.lockedCorrect),
      );
      expect(
        service.statusOf(5),
        equals(ClassificationCardStatus.lockedCorrect),
      );
      expect(
        service.statusOf(6),
        equals(ClassificationCardStatus.lockedCorrect),
      );
      expect(
        service.statusOf(7),
        equals(ClassificationCardStatus.lockedCorrect),
      );

      // Fix and re-verify — locked cards stay locked
      service.placeCard(4, TrophicLevel.secondaryConsumer);
      final result = service.verify();
      expect(result.correctIds.length, equals(7));
    });
  });

  group('verify — edge cases', () {
    test('verify with no config returns empty result', () {
      final emptyService = ClassificationService();
      final result = emptyService.verify();

      expect(result.correctIds, isEmpty);
      expect(result.incorrectIds, isEmpty);
      expect(result.isComplete, isFalse);
    });

    test('verify when canVerify is false returns empty result', () {
      service.placeCard(1, TrophicLevel.producer);
      final result = service.verify();

      expect(result.correctIds, isEmpty);
      expect(result.incorrectIds, isEmpty);
      expect(result.isComplete, isFalse);
    });
  });

  group('getHint', () {
    test('returns conceptual hint first', () {
      final hint = service.getHint(4); // Sapo

      expect(hint, isNotNull);
      expect(hint!.level, equals(HintLevel.conceptual));
      expect(hint.highlightedLevel, isNull);
      expect(hint.message, isNotEmpty);
    });

    test('returns relational hint second', () {
      service.getHint(4); // conceptual
      final hint = service.getHint(4); // relational

      expect(hint, isNotNull);
      expect(hint!.level, equals(HintLevel.relational));
      expect(hint.highlightedLevel, isNull);
    });

    test('returns directional hint third with highlighted level', () {
      service.getHint(4); // conceptual
      service.getHint(4); // relational
      final hint = service.getHint(4); // directional

      expect(hint, isNotNull);
      expect(hint!.level, equals(HintLevel.directional));
      expect(hint.highlightedLevel, equals(TrophicLevel.secondaryConsumer));
    });

    test('returns null when all hints exhausted', () {
      service.getHint(4);
      service.getHint(4);
      service.getHint(4);
      final hint = service.getHint(4);

      expect(hint, isNull);
    });

    test('returns null for locked correct card', () {
      _placeAllCorrectly(service);
      service.verify();

      final hint = service.getHint(1);
      expect(hint, isNull);
    });

    test('throws for unknown organism', () {
      expect(() => service.getHint(999), throwsArgumentError);
    });
  });

  group('resetCards', () {
    test('returns all cards to shelf, keeps config', () {
      _placeAllCorrectly(service);
      service.verify();
      expect(service.isComplete, isTrue);

      service.resetCards();

      expect(service.hasConfig, isTrue);
      expect(service.isComplete, isFalse);
      expect(service.placedCount, equals(0));
      expect(service.correctCount, equals(0));
      expect(service.lastResult, isNull);

      for (final org in service.config!.organisms) {
        expect(
          service.statusOf(org.organismId),
          equals(ClassificationCardStatus.shelf),
        );
      }
    });
  });

  group('score and stars integration', () {
    test('all first try — 700 points, 3 stars', () {
      _placeAllCorrectly(service);
      service.verify();

      expect(service.score, equals(700));
      expect(service.stars, equals(3));
      expect(service.maxScore, equals(700));
    });

    test('all later try — 350 points, 1 star', () {
      // Place everything wrong first
      service.placeCard(1, TrophicLevel.tertiaryConsumer);
      service.placeCard(2, TrophicLevel.producer);
      service.placeCard(3, TrophicLevel.producer);
      service.placeCard(4, TrophicLevel.producer);
      service.placeCard(5, TrophicLevel.producer);
      service.placeCard(6, TrophicLevel.producer);
      service.placeCard(7, TrophicLevel.producer);
      service.verify();

      // Fix everything
      _placeAllCorrectly(service);
      service.verify();

      expect(service.score, equals(280)); // 7×50 - 7×10
      expect(service.stars, equals(1)); // 280/700 = 0.4
    });

    test('with hint penalties', () {
      _placeAllCorrectly(service);
      service.getHint(5); // conceptual
      service.getHint(5); // relational
      service.verify();

      // 7×100 - 1×2(conceptual) - 1×5(relational) = 693
      expect(service.score, equals(693));
      expect(service.stars, equals(3)); // 693/700 = 0.99
    });

    test('with all hint levels used', () {
      _placeAllCorrectly(service);
      service.getHint(5); // conceptual
      service.getHint(5); // relational
      service.getHint(5); // directional
      service.verify();

      // 700 - 2 - 5 - 10 = 683
      expect(service.score, equals(683));
    });

    test('score never negative with many penalties', () {
      // Verify wrong 50+ times
      for (int i = 0; i < 10; i++) {
        service.placeCard(1, TrophicLevel.tertiaryConsumer);
        service.placeCard(2, TrophicLevel.producer);
        service.placeCard(3, TrophicLevel.producer);
        service.placeCard(4, TrophicLevel.producer);
        service.placeCard(5, TrophicLevel.producer);
        service.placeCard(6, TrophicLevel.producer);
        service.placeCard(7, TrophicLevel.producer);
        service.verify();
      }

      // Eventually fix all
      _placeAllCorrectly(service);
      service.verify();

      expect(service.score, greaterThanOrEqualTo(0));
      // With 10 verifies × 7 wrong = 70 wrong placements = 700 penalty
      // 7 later try × 50 = 350 - 700 = -350 → clamped to 0
      expect(service.score, equals(0));
      expect(service.stars, equals(1));
    });

    test('score with mix of first try and later try with hints', () {
      // 4 correct first try
      service.placeCard(1, TrophicLevel.producer);
      service.placeCard(3, TrophicLevel.producer); // Coelho → wrong
      service.placeCard(4, TrophicLevel.secondaryConsumer);
      service.placeCard(5, TrophicLevel.secondaryConsumer); // Cobra → wrong
      service.placeCard(6, TrophicLevel.tertiaryConsumer);
      service.placeCard(7, TrophicLevel.tertiaryConsumer);
      service.placeCard(2, TrophicLevel.tertiaryConsumer); // Gafanhoto → wrong
      service.getHint(5); // conceptual hint
      service.verify();

      // Fix 3 wrong + re-verify
      service.placeCard(3, TrophicLevel.primaryConsumer);
      service.placeCard(5, TrophicLevel.tertiaryConsumer);
      service.placeCard(2, TrophicLevel.primaryConsumer);
      service.getHint(3); // relational hint
      service.verify();

      expect(service.isComplete, isTrue);

      // 4 first try × 100 = 400
      // 3 later try × 50 = 150
      // 3 wrong on 1st verify = -30
      // 2 conceptual hints (org 5 + org 3) = -4
      // 0 relational hints (none at count >= 2)
      // Total = 400 + 150 - 30 - 4 = 516
      expect(service.score, equals(516));
      expect(service.stars, equals(2)); // 516/700 = 0.737... ≥ 0.60
    });
  });

  group('verify — no .notifyListeners crash', () {
    // Ensures the service doesn't throw when calling methods
    // in unexpected orders (important for ChangeNotifier safety).

    test('place before load is no-op', () {
      final s = ClassificationService();
      s.placeCard(1, TrophicLevel.producer);
      expect(s.placedCount, equals(0));
    });

    test('verify before load returns empty', () {
      final s = ClassificationService();
      final result = s.verify();

      expect(result.isComplete, isFalse);
      expect(result.correctIds, isEmpty);
    });

    test('resetCards without load is no-op', () {
      final s = ClassificationService();
      s.resetCards(); // should not throw
      expect(s.hasConfig, isFalse);
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

void _placeAllCorrectly(ClassificationService service) {
  for (final org in service.config!.organisms) {
    service.placeCard(org.organismId, org.expectedLevel);
  }
}
