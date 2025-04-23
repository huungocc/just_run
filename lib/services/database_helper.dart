import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'daily_data.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE daily_data (
        date TEXT PRIMARY KEY,
        steps INTEGER,
        startSteps INTEGER,
        calories REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE limit_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        currentLimitSteps TEXT,
        currentLimitCalories TEXT
      )
    ''');
  }

  Future<void> saveData(String date, int steps, int startSteps, double calories) async {
    final db = await database;
    await db.insert(
      'daily_data',
      {'date': date, 'steps': steps, 'startSteps': startSteps,'calories': calories},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> loadData(String date) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'daily_data',
      where: 'date = ?',
      whereArgs: [date],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<String?> loadLatestDate() async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'daily_data',
      columns: ['date'],
      orderBy: 'date DESC',
      limit: 1,
    );
    if (results.isNotEmpty) {
      return results.first['date'];
    }
    return null;
  }

  Future<int?> loadStartSteps(String date) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'daily_data',
      columns: ['startSteps'],
      where: 'date = ?',
      whereArgs: [date],
    );
    if (results.isNotEmpty) {
      return results.first['startSteps'] as int;
    }
    return null;
  }

  Future<void> saveLimit(String currentLimitSteps, String currentLimitCalories) async {
    final db = await database;
    await db.insert(
      'limit_data',
      {'currentLimitSteps': currentLimitSteps, 'currentLimitCalories': currentLimitCalories},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, String>?> loadLimit() async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'limit_data',
      orderBy: 'id DESC',
      limit: 1,
    );
    if (results.isNotEmpty) {
      return {
        'currentLimitSteps': results.first['currentLimitSteps'],
        'currentLimitCalories': results.first['currentLimitCalories'],
      };
    }
    return null;
  }
}
