import '../database/database_helper.dart';
import '../models/score.dart';

class ScoreRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(Score score) async {
    final db = await _dbHelper.database;
    return await db.insert('scores', score.toMap());
  }

  Future<List<Score>> getByPhaseId(int phaseId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'scores',
      where: 'phase_id = ?',
      whereArgs: [phaseId],
      orderBy: 'score DESC',
    );
    return maps.map((m) => Score.fromMap(m)).toList();
  }

  Future<List<Score>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('scores', orderBy: 'score DESC');
    return maps.map((m) => Score.fromMap(m)).toList();
  }

  Future<Score?> getBestByPhaseId(int phaseId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'scores',
      where: 'phase_id = ?',
      whereArgs: [phaseId],
      orderBy: 'stars DESC, score DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Score.fromMap(maps.first);
  }

  Future<void> deleteAll() async {
    final db = await _dbHelper.database;
    await db.delete('scores');
  }

  Future<bool> isPhaseUnlocked(int phaseId) async {
    if (phaseId == 1) return true;
    final db = await _dbHelper.database;
    final maps = await db.query(
      'scores',
      where: 'phase_id = ? AND stars >= 1',
      whereArgs: [phaseId - 1],
      limit: 1,
    );
    return maps.isNotEmpty;
  }
}
