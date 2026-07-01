import 'package:sqflite/sqflite.dart';

class DatabaseSeed {
  static Future<void> seed(Database db) async {
    await _insertPhases(db);
    await _insertOrganisms(db);
    await _insertConnections(db);
  }

  static Future<void> _insertPhases(Database db) async {
    await db.insert('phases', {
      'id': 1,
      'name': 'Campo',
      'description': 'Monte a teia alimentar do campo',
      'biome': 'campo',
      'sort_order': 1,
    });
    await db.insert('phases', {
      'id': 2,
      'name': 'Floresta',
      'description': 'Monte a teia alimentar da floresta',
      'biome': 'floresta',
      'sort_order': 2,
    });
    await db.insert('phases', {
      'id': 3,
      'name': 'Oceano',
      'description': 'Monte a teia alimentar do oceano',
      'biome': 'oceano',
      'sort_order': 3,
    });
    await db.insert('phases', {
      'id': 4,
      'name': 'Pantanal',
      'description': 'Monte a teia alimentar do pantanal',
      'biome': 'pantanal',
      'sort_order': 4,
    });
  }

  static Future<void> _insertOrganisms(Database db) async {
    await db.insert('organisms', {
      'id': 1,
      'phase_id': 1,
      'name': 'Capim',
      'emoji': '🌱',
      'trophic_level': 'produtor',
      'position_x': 0.50,
      'position_y': 0.85,
    });
    await db.insert('organisms', {
      'id': 2,
      'phase_id': 1,
      'name': 'Gafanhoto',
      'emoji': '🦗',
      'trophic_level': 'consumidor_primario',
      'position_x': 0.25,
      'position_y': 0.66,
    });
    await db.insert('organisms', {
      'id': 3,
      'phase_id': 1,
      'name': 'Coelho',
      'emoji': '🐇',
      'trophic_level': 'consumidor_primario',
      'position_x': 0.75,
      'position_y': 0.66,
    });
    await db.insert('organisms', {
      'id': 4,
      'phase_id': 1,
      'name': 'Sapo',
      'emoji': '🐸',
      'trophic_level': 'consumidor_secundario',
      'position_x': 0.50,
      'position_y': 0.48,
    });
    await db.insert('organisms', {
      'id': 5,
      'phase_id': 1,
      'name': 'Cobra',
      'emoji': '🐍',
      'trophic_level': 'consumidor_terciario',
      'position_x': 0.50,
      'position_y': 0.28,
    });
    await db.insert('organisms', {
      'id': 6,
      'phase_id': 1,
      'name': 'Raposa',
      'emoji': '🦊',
      'trophic_level': 'predador_topo',
      'position_x': 0.25,
      'position_y': 0.06,
    });
    await db.insert('organisms', {
      'id': 7,
      'phase_id': 1,
      'name': 'Águia',
      'emoji': '🦅',
      'trophic_level': 'predador_topo',
      'position_x': 0.75,
      'position_y': 0.06,
    });
    await db.insert('organisms', {
      'id': 8,
      'phase_id': 2,
      'name': 'Arbusto',
      'emoji': '🌿',
      'trophic_level': 'produtor',
      'position_x': 0.50,
      'position_y': 0.85,
    });
    await db.insert('organisms', {
      'id': 9,
      'phase_id': 2,
      'name': 'Lagarta',
      'emoji': '🐛',
      'trophic_level': 'consumidor_primario',
      'position_x': 0.25,
      'position_y': 0.66,
    });
    await db.insert('organisms', {
      'id': 10,
      'phase_id': 2,
      'name': 'Aranha',
      'emoji': '🕷️',
      'trophic_level': 'consumidor_secundario',
      'position_x': 0.25,
      'position_y': 0.48,
    });
    await db.insert('organisms', {
      'id': 11,
      'phase_id': 2,
      'name': 'Sapo',
      'emoji': '🐸',
      'trophic_level': 'consumidor_secundario',
      'position_x': 0.75,
      'position_y': 0.48,
    });
    await db.insert('organisms', {
      'id': 12,
      'phase_id': 2,
      'name': 'Cobra',
      'emoji': '🐍',
      'trophic_level': 'consumidor_terciario',
      'position_x': 0.50,
      'position_y': 0.28,
    });
    await db.insert('organisms', {
      'id': 13,
      'phase_id': 2,
      'name': 'Gavião',
      'emoji': '🦅',
      'trophic_level': 'predador_topo',
      'position_x': 0.25,
      'position_y': 0.06,
    });
    await db.insert('organisms', {
      'id': 14,
      'phase_id': 2,
      'name': 'Veado',
      'emoji': '🦌',
      'trophic_level': 'consumidor_primario',
      'position_x': 0.75,
      'position_y': 0.66,
    });
    await db.insert('organisms', {
      'id': 15,
      'phase_id': 2,
      'name': 'Onça-pintada',
      'emoji': '🐆',
      'trophic_level': 'predador_topo',
      'position_x': 0.75,
      'position_y': 0.06,
    });
    await db.insert('organisms', {
      'id': 16,
      'phase_id': 3,
      'name': 'Fitoplâncton',
      'emoji': '🦠',
      'trophic_level': 'produtor',
      'position_x': 0.30,
      'position_y': 0.85,
    });
    await db.insert('organisms', {
      'id': 17,
      'phase_id': 3,
      'name': 'Alga',
      'emoji': '🌿',
      'trophic_level': 'produtor',
      'position_x': 0.70,
      'position_y': 0.85,
    });
    await db.insert('organisms', {
      'id': 18,
      'phase_id': 3,
      'name': 'Camarão',
      'emoji': '🦐',
      'trophic_level': 'consumidor_primario',
      'position_x': 0.50,
      'position_y': 0.66,
    });
    await db.insert('organisms', {
      'id': 19,
      'phase_id': 3,
      'name': 'Sardinha',
      'emoji': '🐟',
      'trophic_level': 'consumidor_secundario',
      'position_x': 0.50,
      'position_y': 0.48,
    });
    await db.insert('organisms', {
      'id': 20,
      'phase_id': 3,
      'name': 'Polvo',
      'emoji': '🐙',
      'trophic_level': 'consumidor_terciario',
      'position_x': 0.30,
      'position_y': 0.28,
    });
    await db.insert('organisms', {
      'id': 21,
      'phase_id': 3,
      'name': 'Atum',
      'emoji': '🐠',
      'trophic_level': 'consumidor_terciario',
      'position_x': 0.70,
      'position_y': 0.28,
    });
    await db.insert('organisms', {
      'id': 22,
      'phase_id': 3,
      'name': 'Tubarão',
      'emoji': '🦈',
      'trophic_level': 'predador_topo',
      'position_x': 0.50,
      'position_y': 0.06,
    });
    await db.insert('organisms', {
      'id': 23,
      'phase_id': 4,
      'name': 'Planta aquática',
      'emoji': '🌱',
      'trophic_level': 'produtor',
      'position_x': 0.50,
      'position_y': 0.85,
    });
    await db.insert('organisms', {
      'id': 24,
      'phase_id': 4,
      'name': 'Caramujo',
      'emoji': '🐌',
      'trophic_level': 'consumidor_primario',
      'position_x': 0.50,
      'position_y': 0.66,
    });
    await db.insert('organisms', {
      'id': 25,
      'phase_id': 4,
      'name': 'Peixe',
      'emoji': '🐟',
      'trophic_level': 'consumidor_secundario',
      'position_x': 0.50,
      'position_y': 0.48,
    });
    await db.insert('organisms', {
      'id': 26,
      'phase_id': 4,
      'name': 'Garça',
      'emoji': '🦅',
      'trophic_level': 'consumidor_terciario',
      'position_x': 0.30,
      'position_y': 0.28,
    });
    await db.insert('organisms', {
      'id': 27,
      'phase_id': 4,
      'name': 'Jacaré',
      'emoji': '🐊',
      'trophic_level': 'consumidor_terciario',
      'position_x': 0.70,
      'position_y': 0.28,
    });
    await db.insert('organisms', {
      'id': 28,
      'phase_id': 4,
      'name': 'Cobra sucuri',
      'emoji': '🐍',
      'trophic_level': 'predador_topo',
      'position_x': 0.30,
      'position_y': 0.06,
    });
    await db.insert('organisms', {
      'id': 29,
      'phase_id': 4,
      'name': 'Onça-pintada',
      'emoji': '🐆',
      'trophic_level': 'predador_topo',
      'position_x': 0.70,
      'position_y': 0.06,
    });
  }

  static Future<void> _insertConnections(Database db) async {
    final connections = <Map<String, dynamic>>[
      {'id': 1, 'phase_id': 1, 'source_id': 1, 'target_id': 2},
      {'id': 2, 'phase_id': 1, 'source_id': 1, 'target_id': 3},
      {'id': 3, 'phase_id': 1, 'source_id': 2, 'target_id': 4},
      {'id': 5, 'phase_id': 1, 'source_id': 3, 'target_id': 5},
      {'id': 6, 'phase_id': 1, 'source_id': 3, 'target_id': 6},
      {'id': 7, 'phase_id': 1, 'source_id': 3, 'target_id': 7},
      {'id': 8, 'phase_id': 1, 'source_id': 4, 'target_id': 5},
      {'id': 9, 'phase_id': 1, 'source_id': 5, 'target_id': 7},
      {'id': 11, 'phase_id': 2, 'source_id': 8, 'target_id': 9},
      {'id': 12, 'phase_id': 2, 'source_id': 8, 'target_id': 14},
      {'id': 13, 'phase_id': 2, 'source_id': 9, 'target_id': 10},
      {'id': 14, 'phase_id': 2, 'source_id': 9, 'target_id': 11},
      {'id': 15, 'phase_id': 2, 'source_id': 10, 'target_id': 11},
      {'id': 16, 'phase_id': 2, 'source_id': 11, 'target_id': 12},
      {'id': 17, 'phase_id': 2, 'source_id': 12, 'target_id': 13},
      {'id': 18, 'phase_id': 2, 'source_id': 12, 'target_id': 15},
      {'id': 19, 'phase_id': 2, 'source_id': 14, 'target_id': 15},
      {'id': 20, 'phase_id': 3, 'source_id': 16, 'target_id': 18},
      {'id': 21, 'phase_id': 3, 'source_id': 17, 'target_id': 18},
      {'id': 22, 'phase_id': 3, 'source_id': 18, 'target_id': 19},
      {'id': 23, 'phase_id': 3, 'source_id': 18, 'target_id': 20},
      {'id': 24, 'phase_id': 3, 'source_id': 19, 'target_id': 21},
      {'id': 25, 'phase_id': 3, 'source_id': 19, 'target_id': 20},
      {'id': 26, 'phase_id': 3, 'source_id': 21, 'target_id': 22},
      {'id': 27, 'phase_id': 3, 'source_id': 20, 'target_id': 22},
      {'id': 28, 'phase_id': 4, 'source_id': 23, 'target_id': 24},
      {'id': 29, 'phase_id': 4, 'source_id': 23, 'target_id': 25},
      {'id': 30, 'phase_id': 4, 'source_id': 24, 'target_id': 25},
      {'id': 31, 'phase_id': 4, 'source_id': 25, 'target_id': 26},
      {'id': 32, 'phase_id': 4, 'source_id': 25, 'target_id': 27},
      {'id': 33, 'phase_id': 4, 'source_id': 25, 'target_id': 28},
      {'id': 34, 'phase_id': 4, 'source_id': 27, 'target_id': 29},
      {'id': 35, 'phase_id': 4, 'source_id': 26, 'target_id': 29},
      {'id': 36, 'phase_id': 4, 'source_id': 27, 'target_id': 28},
    ];
    for (final c in connections) {
      await db.insert('correct_connections', c);
    }
  }
}
