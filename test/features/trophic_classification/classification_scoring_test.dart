import 'package:flutter_test/flutter_test.dart';
import 'package:food_web_builder/features/trophic_classification/services/classification_scoring.dart';

void main() {
  final scoring = ClassificationScoring();

  group('ClassificationScoring.calculateScore', () {
    test('all correct on first try — maximum score', () {
      final score = scoring.calculateScore(
        firstTryCorrectCount: 7,
        laterTryCorrectCount: 0,
        wrongPlacements: 0,
        conceptualHints: 0,
        relationalHints: 0,
        directionalHints: 0,
      );
      expect(score, equals(700)); // 7 × 100
    });

    test('correct on later attempts — uses 50 points each', () {
      final score = scoring.calculateScore(
        firstTryCorrectCount: 0,
        laterTryCorrectCount: 7,
        wrongPlacements: 0,
        conceptualHints: 0,
        relationalHints: 0,
        directionalHints: 0,
      );
      expect(score, equals(350)); // 7 × 50
    });

    test('mix of first try and later try', () {
      final score = scoring.calculateScore(
        firstTryCorrectCount: 4,
        laterTryCorrectCount: 3,
        wrongPlacements: 0,
        conceptualHints: 0,
        relationalHints: 0,
        directionalHints: 0,
      );
      expect(score, equals(550)); // 4×100 + 3×50
    });

    test('penalty for wrong placements', () {
      final score = scoring.calculateScore(
        firstTryCorrectCount: 5,
        laterTryCorrectCount: 2,
        wrongPlacements: 3,
        conceptualHints: 0,
        relationalHints: 0,
        directionalHints: 0,
      );
      expect(score, equals(570)); // 5×100 + 2×50 - 3×10
    });

    test('penalty for conceptual hints', () {
      final score = scoring.calculateScore(
        firstTryCorrectCount: 7,
        laterTryCorrectCount: 0,
        wrongPlacements: 0,
        conceptualHints: 2,
        relationalHints: 0,
        directionalHints: 0,
      );
      expect(score, equals(696)); // 700 - 2×2
    });

    test('penalty for relational hints', () {
      final score = scoring.calculateScore(
        firstTryCorrectCount: 7,
        laterTryCorrectCount: 0,
        wrongPlacements: 0,
        conceptualHints: 0,
        relationalHints: 1,
        directionalHints: 0,
      );
      expect(score, equals(695)); // 700 - 1×5
    });

    test('penalty for directional hints', () {
      final score = scoring.calculateScore(
        firstTryCorrectCount: 7,
        laterTryCorrectCount: 0,
        wrongPlacements: 0,
        conceptualHints: 0,
        relationalHints: 0,
        directionalHints: 3,
      );
      expect(score, equals(670)); // 700 - 3×10
    });

    test('all three hint levels combined', () {
      final score = scoring.calculateScore(
        firstTryCorrectCount: 5,
        laterTryCorrectCount: 2,
        wrongPlacements: 2,
        conceptualHints: 1,
        relationalHints: 2,
        directionalHints: 1,
      );
      // 5×100 + 2×50 - 2×10 - 1×2 - 2×5 - 1×10
      // = 500 + 100 - 20 - 2 - 10 - 10 = 558
      expect(score, equals(558));
    });

    test('score is never negative (large penalties)', () {
      final score = scoring.calculateScore(
        firstTryCorrectCount: 0,
        laterTryCorrectCount: 0,
        wrongPlacements: 100,
        conceptualHints: 100,
        relationalHints: 100,
        directionalHints: 100,
      );
      expect(score, equals(0));
    });

    test('score is never negative (zero correct, many penalties)', () {
      final score = scoring.calculateScore(
        firstTryCorrectCount: 0,
        laterTryCorrectCount: 0,
        wrongPlacements: 50,
        conceptualHints: 0,
        relationalHints: 0,
        directionalHints: 0,
      );
      expect(score, equals(0));
    });

    test('score is never negative (penalties slightly exceed points)', () {
      final score = scoring.calculateScore(
        firstTryCorrectCount: 1,
        laterTryCorrectCount: 0,
        wrongPlacements: 15,
        conceptualHints: 0,
        relationalHints: 0,
        directionalHints: 0,
      );
      // 100 - 150 = -50 → clamped to 0
      expect(score, equals(0));
    });

    test('all zeros yields zero', () {
      final score = scoring.calculateScore(
        firstTryCorrectCount: 0,
        laterTryCorrectCount: 0,
        wrongPlacements: 0,
        conceptualHints: 0,
        relationalHints: 0,
        directionalHints: 0,
      );
      expect(score, equals(0));
    });
  });

  group('ClassificationScoring.calculateStars', () {
    test('3 stars when ratio >= 0.85', () {
      expect(scoring.calculateStars(score: 85, maxScore: 100), equals(3));
      expect(scoring.calculateStars(score: 595, maxScore: 700), equals(3));
      expect(scoring.calculateStars(score: 700, maxScore: 700), equals(3));
    });

    test('2 stars when ratio >= 0.60 and < 0.85', () {
      expect(scoring.calculateStars(score: 60, maxScore: 100), equals(2));
      expect(scoring.calculateStars(score: 420, maxScore: 700), equals(2));
      expect(scoring.calculateStars(score: 594, maxScore: 700), equals(2));
    });

    test('1 star when ratio < 0.60', () {
      expect(scoring.calculateStars(score: 59, maxScore: 100), equals(1));
      expect(scoring.calculateStars(score: 0, maxScore: 100), equals(1));
      expect(scoring.calculateStars(score: 350, maxScore: 700), equals(1));
    });

    test('boundary: exactly 0.85 gives 3 stars', () {
      expect(scoring.calculateStars(score: 85, maxScore: 100), equals(3));
    });

    test('boundary: exactly 0.60 gives 2 stars', () {
      expect(scoring.calculateStars(score: 60, maxScore: 100), equals(2));
    });

    test('boundary: just under 0.85 gives 2 stars', () {
      // 594 / 700 = 0.8485... < 0.85
      expect(scoring.calculateStars(score: 594, maxScore: 700), equals(2));
    });

    test('boundary: just under 0.60 gives 1 star', () {
      // 419 / 700 = 0.5985... < 0.60
      expect(scoring.calculateStars(score: 419, maxScore: 700), equals(1));
    });

    test('maxScore <= 0 returns 1 star', () {
      expect(scoring.calculateStars(score: 0, maxScore: 0), equals(1));
      expect(scoring.calculateStars(score: 100, maxScore: 0), equals(1));
      expect(scoring.calculateStars(score: 100, maxScore: -1), equals(1));
    });
  });
}
