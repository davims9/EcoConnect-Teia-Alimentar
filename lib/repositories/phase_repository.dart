import '../database/database_helper.dart';
import '../models/phase.dart';

class PhaseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Phase>> getAll() async {
    final db = await _dbHelper.database;
    // ignore: avoid_print
    print('[PhaseRepo] db obtained');
    final maps = await db.query('phases', orderBy: 'sort_order ASC');
    // ignore: avoid_print
    print('[PhaseRepo] ${maps.length} phases found');
    return maps.map((m) => Phase.fromMap(m)).toList();
  }

  Future<Phase?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('phases', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Phase.fromMap(maps.first);
  }
}
