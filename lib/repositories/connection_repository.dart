import '../database/database_helper.dart';
import '../models/correct_connection.dart';

class ConnectionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<CorrectConnection>> getByPhaseId(int phaseId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'correct_connections',
      where: 'phase_id = ?',
      whereArgs: [phaseId],
    );
    return maps.map((m) => CorrectConnection.fromMap(m)).toList();
  }

  Future<Set<String>> getConnectionKeysByPhaseId(int phaseId) async {
    final connections = await getByPhaseId(phaseId);
    return connections.map((c) => c.key).toSet();
  }
}
