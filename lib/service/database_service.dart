import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:web_scraping/models/job_ad.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'jobs_database.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            url TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertJob(JobAd job) async {
    final db = await database;
    await db.insert(
      'favorites',
      job.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<JobAd>> getFavoriteJobs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    return List.generate(maps.length, (i) {
      return JobAd(
        title: maps[i]['title'],
        url: maps[i]['url'],
      );
    });
  }

  Future<void> deleteJob(String url) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'url = ?',
      whereArgs: [url],
    );
  }

  Future<bool> isFavorite(String url) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'url = ?',
      whereArgs: [url],
    );
    return maps.isNotEmpty;
  }
}
