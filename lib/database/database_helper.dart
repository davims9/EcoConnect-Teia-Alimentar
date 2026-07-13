import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';
import '../core/app_constants.dart';
import 'database_seed.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._();

  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = kIsWeb
        ? AppConstants.dbName
        : '${await getDatabasesPath()}/${AppConstants.dbName}';

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE phases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        biome TEXT NOT NULL,
        sort_order INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE organisms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phase_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        emoji TEXT NOT NULL,
        trophic_level TEXT NOT NULL,
        position_x REAL NOT NULL,
        position_y REAL NOT NULL,
        FOREIGN KEY (phase_id) REFERENCES phases(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE correct_connections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phase_id INTEGER NOT NULL,
        source_id INTEGER NOT NULL,
        target_id INTEGER NOT NULL,
        FOREIGN KEY (phase_id) REFERENCES phases(id) ON DELETE CASCADE,
        FOREIGN KEY (source_id) REFERENCES organisms(id) ON DELETE CASCADE,
        FOREIGN KEY (target_id) REFERENCES organisms(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phase_id INTEGER NOT NULL,
        player_name TEXT NOT NULL,
        score INTEGER NOT NULL,
        stars INTEGER NOT NULL,
        errors INTEGER NOT NULL,
        completed_at TEXT NOT NULL,
        FOREIGN KEY (phase_id) REFERENCES phases(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE classification_scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        classification_phase_key TEXT NOT NULL,
        biome_phase_id INTEGER NOT NULL,
        player_name TEXT NOT NULL,
        score INTEGER NOT NULL,
        max_score INTEGER NOT NULL,
        stars INTEGER NOT NULL,
        wrong_placements INTEGER NOT NULL,
        hints_used INTEGER NOT NULL DEFAULT 0,
        attempts INTEGER NOT NULL,
        completed_at TEXT NOT NULL,
        FOREIGN KEY (biome_phase_id) REFERENCES phases(id) ON DELETE CASCADE
      )
    ''');

    await DatabaseSeed.seed(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE classification_scores (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          classification_phase_key TEXT NOT NULL,
          biome_phase_id INTEGER NOT NULL,
          player_name TEXT NOT NULL,
          score INTEGER NOT NULL,
          max_score INTEGER NOT NULL,
          stars INTEGER NOT NULL,
          wrong_placements INTEGER NOT NULL,
          hints_used INTEGER NOT NULL DEFAULT 0,
          attempts INTEGER NOT NULL,
          completed_at TEXT NOT NULL,
          FOREIGN KEY (biome_phase_id) REFERENCES phases(id) ON DELETE CASCADE
        )
      ''');
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Resets the singleton for testing purposes only.
  ///
  /// Must call [close] before calling this to release the database.
  @visibleForTesting
  static void resetForTesting() {
    _instance = null;
    _database = null;
  }
}
