import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('news_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT
      )
    ''');

    // Articles cache table
    await db.execute('''
      CREATE TABLE articles (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        content TEXT,
        source TEXT,
        url TEXT,
        category_id TEXT,
        image_url TEXT,
        published_at TEXT,
        cached_at INTEGER NOT NULL
      )
    ''');

    // Favorites cache table isolated by user_id
    await db.execute('''
      CREATE TABLE favorites (
        user_id TEXT NOT NULL,
        article_id TEXT NOT NULL,
        created_at TEXT,
        PRIMARY KEY (user_id, article_id)
      )
    ''');
  }

  Future<void> clearUserFavorites(String userId) async {
    final db = await database;
    await db.delete('favorites', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
