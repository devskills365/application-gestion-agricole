// lib/services/database_service.dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/sac.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<void> init() async {
    _database = await _initDb();
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'agricole.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sacs(
            uuid TEXT PRIMARY KEY,
            producteur_id TEXT,
            nom_producteur TEXT,
            region_producteur TEXT,
            poids TEXT,
            date_recolte TEXT,
            qualite TEXT,
            est_synchronise INTEGER
          )
        ''');
      },
    );
  }

  // C'est la seule méthode de sauvegarde que vous devriez utiliser.
  Future<void> saveSac(Sac sac) async {
    final db = await database;
    await db.insert(
      'sacs',
      sac.toMap(),
      // Utilisation de replace pour mettre à jour si l'UUID existe, sinon insérer.
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Sac>> getSacsNonSynchronises() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sacs',
      where: 'est_synchronise = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) {
      return Sac.fromMap(maps[i]);
    });
  }

  Future<List<Sac>> getSacs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('sacs');
    return List.generate(maps.length, (i) {
      return Sac.fromMap(maps[i]);
    });
  }

  Future<void> marquerCommeSynchronise(String uuid) async {
    final db = await database;
    await db.update(
      'sacs',
      {'est_synchronise': 1},
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
  }
}