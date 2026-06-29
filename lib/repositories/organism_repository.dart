import '../database/database_helper.dart';
import '../models/organism.dart';

class OrganismRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Organism>> getByPhaseId(int phaseId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'organisms',
      where: 'phase_id = ?',
      whereArgs: [phaseId],
    );
    return maps.map((m) => Organism.fromMap(m)).toList();
  }
}
