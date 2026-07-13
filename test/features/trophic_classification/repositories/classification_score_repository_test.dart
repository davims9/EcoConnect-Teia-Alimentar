import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:food_web_builder/database/database_helper.dart';
import 'package:food_web_builder/features/trophic_classification/models/classification_score.dart';
import 'package:food_web_builder/features/trophic_classification/repositories/classification_score_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final db = await DatabaseHelper.instance.database;
    // Ensure database is ready (triggers onCreate/onUpgrade).
    expect(db, isNotNull);
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
    DatabaseHelper.resetForTesting();
  });

  group('ClassificationScoreRepository', () {
    late ClassificationScoreRepository repo;

    setUp(() async {
      repo = ClassificationScoreRepository();
      // Clear table to prevent state leaking between tests
      // (DatabaseHelper is a singleton with a file-based database).
      final db = await DatabaseHelper.instance.database;
      await db.delete('classification_scores');
    });

    test('insert returns a non-zero id', () async {
      final score = ClassificationScore(
        classificationPhaseKey: 'test_phase',
        biomePhaseId: 1,
        playerName: 'Test',
        score: 100,
        maxScore: 120,
        stars: 3,
        wrongPlacements: 1,
        hintsUsed: 0,
        attempts: 2,
        completedAt: '2025-01-01T00:00:00',
      );

      final id = await repo.insert(score);

      expect(id, greaterThan(0));
    });

    test('getByClassificationPhaseKey returns matching scores', () async {
      // Insert two scores for the same phase key.
      await repo.insert(
        ClassificationScore(
          classificationPhaseKey: 'phase_a',
          biomePhaseId: 1,
          playerName: 'P1',
          score: 80,
          maxScore: 120,
          stars: 2,
          wrongPlacements: 2,
          hintsUsed: 1,
          attempts: 3,
          completedAt: '2025-01-01T00:00:00',
        ),
      );
      await repo.insert(
        ClassificationScore(
          classificationPhaseKey: 'phase_a',
          biomePhaseId: 1,
          playerName: 'P2',
          score: 100,
          maxScore: 120,
          stars: 3,
          wrongPlacements: 0,
          hintsUsed: 0,
          attempts: 1,
          completedAt: '2025-01-02T00:00:00',
        ),
      );
      // Insert one for a different phase key.
      await repo.insert(
        ClassificationScore(
          classificationPhaseKey: 'phase_b',
          biomePhaseId: 2,
          playerName: 'P3',
          score: 50,
          maxScore: 100,
          stars: 1,
          wrongPlacements: 5,
          hintsUsed: 3,
          attempts: 4,
          completedAt: '2025-01-03T00:00:00',
        ),
      );

      final results = await repo.getByClassificationPhaseKey('phase_a');

      expect(results.length, 2);
      // Results ordered by score DESC (100 then 80).
      expect(results[0].score, 100);
      expect(results[0].playerName, 'P2');
      expect(results[1].score, 80);
      expect(results[1].playerName, 'P1');
    });

    test('getBestByClassificationPhaseKey returns highest stars', () async {
      await repo.insert(
        ClassificationScore(
          classificationPhaseKey: 'best_test',
          biomePhaseId: 1,
          playerName: 'Low',
          score: 40,
          maxScore: 120,
          stars: 1,
          wrongPlacements: 5,
          hintsUsed: 2,
          attempts: 4,
          completedAt: '2025-01-01T00:00:00',
        ),
      );
      await repo.insert(
        ClassificationScore(
          classificationPhaseKey: 'best_test',
          biomePhaseId: 1,
          playerName: 'Best',
          score: 110,
          maxScore: 120,
          stars: 3,
          wrongPlacements: 0,
          hintsUsed: 0,
          attempts: 1,
          completedAt: '2025-01-02T00:00:00',
        ),
      );
      await repo.insert(
        ClassificationScore(
          classificationPhaseKey: 'best_test',
          biomePhaseId: 1,
          playerName: 'Mid',
          score: 75,
          maxScore: 120,
          stars: 2,
          wrongPlacements: 2,
          hintsUsed: 1,
          attempts: 2,
          completedAt: '2025-01-03T00:00:00',
        ),
      );

      final best = await repo.getBestByClassificationPhaseKey('best_test');

      expect(best, isNotNull);
      expect(best!.stars, 3);
      expect(best.playerName, 'Best');
      expect(best.score, 110);
    });

    test(
      'getBestByClassificationPhaseKey returns null when no scores',
      () async {
        final best = await repo.getBestByClassificationPhaseKey('nonexistent');

        expect(best, isNull);
      },
    );

    test('isUnlocked returns true when stars >= 1', () async {
      await repo.insert(
        ClassificationScore(
          classificationPhaseKey: 'unlock_test',
          biomePhaseId: 1,
          playerName: 'Test',
          score: 50,
          maxScore: 100,
          stars: 1,
          wrongPlacements: 4,
          hintsUsed: 2,
          attempts: 3,
          completedAt: '2025-01-01T00:00:00',
        ),
      );

      final unlocked = await repo.isUnlocked('unlock_test');

      expect(unlocked, isTrue);
    });

    test('isUnlocked returns false when stars < 1', () async {
      await repo.insert(
        ClassificationScore(
          classificationPhaseKey: 'locked_test',
          biomePhaseId: 1,
          playerName: 'Test',
          score: 20,
          maxScore: 100,
          stars: 0,
          wrongPlacements: 8,
          hintsUsed: 3,
          attempts: 5,
          completedAt: '2025-01-01T00:00:00',
        ),
      );

      final unlocked = await repo.isUnlocked('locked_test');

      expect(unlocked, isFalse);
    });

    test('isUnlocked returns false when no scores', () async {
      final unlocked = await repo.isUnlocked('no_scores_yet');

      expect(unlocked, isFalse);
    });

    test(
      'deleteClassificationProgress removes records for a phase key',
      () async {
        await repo.insert(
          ClassificationScore(
            classificationPhaseKey: 'delete_me',
            biomePhaseId: 1,
            playerName: 'Test',
            score: 100,
            maxScore: 120,
            stars: 3,
            wrongPlacements: 0,
            hintsUsed: 0,
            attempts: 1,
            completedAt: '2025-01-01T00:00:00',
          ),
        );
        await repo.insert(
          ClassificationScore(
            classificationPhaseKey: 'keep_me',
            biomePhaseId: 1,
            playerName: 'Test',
            score: 80,
            maxScore: 120,
            stars: 2,
            wrongPlacements: 2,
            hintsUsed: 1,
            attempts: 2,
            completedAt: '2025-01-01T00:00:00',
          ),
        );

        await repo.deleteClassificationProgress('delete_me');

        final deleted = await repo.getByClassificationPhaseKey('delete_me');
        expect(deleted, isEmpty);

        final kept = await repo.getByClassificationPhaseKey('keep_me');
        expect(kept, hasLength(1));
      },
    );
  });
}
