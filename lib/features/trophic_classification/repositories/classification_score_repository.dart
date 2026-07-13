import '../../../database/database_helper.dart';
import '../models/classification_score.dart';

/// Repository for the `classification_scores` table.
///
/// Follows the same pattern as [ScoreRepository].
/// All queries use the dedicated table — no cross-contamination
/// with the food-web `scores` table.
class ClassificationScoreRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(ClassificationScore score) async {
    final db = await _dbHelper.database;
    return await db.insert('classification_scores', score.toMap());
  }

  Future<List<ClassificationScore>> getByClassificationPhaseKey(
    String phaseKey,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'classification_scores',
      where: 'classification_phase_key = ?',
      whereArgs: [phaseKey],
      orderBy: 'score DESC',
    );
    return maps.map((m) => ClassificationScore.fromMap(m)).toList();
  }

  Future<ClassificationScore?> getBestByClassificationPhaseKey(
    String phaseKey,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'classification_scores',
      where: 'classification_phase_key = ?',
      whereArgs: [phaseKey],
      orderBy: 'stars DESC, score DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ClassificationScore.fromMap(maps.first);
  }

  Future<bool> isUnlocked(String phaseKey) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'classification_scores',
      where: 'classification_phase_key = ? AND stars >= 1',
      whereArgs: [phaseKey],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  Future<void> deleteClassificationProgress(String phaseKey) async {
    final db = await _dbHelper.database;
    await db.delete(
      'classification_scores',
      where: 'classification_phase_key = ?',
      whereArgs: [phaseKey],
    );
  }
}
