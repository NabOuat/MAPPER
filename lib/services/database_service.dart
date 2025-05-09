import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user.dart';
import '../models/place.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'mapper_lite.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Création de la table utilisateurs
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        score INTEGER DEFAULT 0,
        last_active TEXT,
        avatar_url TEXT
      )
    ''');

    // Création de la table lieux
    await db.execute('''
      CREATE TABLE places (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Création de la table achievements (succès)
    await db.execute('''
      CREATE TABLE achievements (
        id_achievement INTEGER PRIMARY KEY AUTOINCREMENT,
        id_utilisateur TEXT NOT NULL,
        achievement_type TEXT NOT NULL,
        date_obtained TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        FOREIGN KEY (id_utilisateur) REFERENCES users (id)
      )
    ''');
  }

  // Méthodes pour les utilisateurs
  Future<void> saveUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<User?> getUser(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  // Méthodes pour les lieux
  Future<String> savePlace(Place place) async {
    final db = await database;
    await db.insert(
      'places',
      place.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return place.id;
  }

  Future<List<Place>> getPlaces({String? userId, String? category}) async {
    final db = await database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (userId != null && category != null) {
      whereClause = 'user_id = ? AND category = ?';
      whereArgs = [userId, category];
    } else if (userId != null) {
      whereClause = 'user_id = ?';
      whereArgs = [userId];
    } else if (category != null) {
      whereClause = 'category = ?';
      whereArgs = [category];
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'places',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    return List.generate(maps.length, (i) {
      return Place.fromMap(maps[i]);
    });
  }

  Future<void> updatePlace(Place place) async {
    final db = await database;
    await db.update(
      'places',
      place.toMap(),
      where: 'id = ?',
      whereArgs: [place.id],
    );
  }

  Future<void> deletePlace(String id) async {
    final db = await database;
    await db.delete(
      'places',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Méthodes pour les achievements
  Future<void> saveAchievement(Map<String, dynamic> achievement) async {
    final db = await database;
    await db.insert(
      'achievements',
      achievement,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getUserAchievements(String userId) async {
    final db = await database;
    return await db.query(
      'achievements',
      where: 'id_utilisateur = ?',
      whereArgs: [userId],
    );
  }

  // Méthodes de synchronisation
  Future<List<Place>> getUnsyncedPlaces() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'places',
      where: 'is_synced = ?',
      whereArgs: [0],
    );

    return List.generate(maps.length, (i) {
      return Place.fromMap(maps[i]);
    });
  }

  Future<void> markPlaceAsSynced(String id) async {
    final db = await database;
    await db.update(
      'places',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getUnsyncedAchievements() async {
    final db = await database;
    return await db.query(
      'achievements',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
  }

  Future<void> markAchievementAsSynced(int id) async {
    final db = await database;
    await db.update(
      'achievements',
      {'is_synced': 1},
      where: 'id_achievement = ?',
      whereArgs: [id],
    );
  }
}
