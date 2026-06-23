import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('interview_ace_v5.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Drop and recreate tables on version change
    await db.execute('DROP TABLE IF EXISTS mcq_bank');
    await db.execute('DROP TABLE IF EXISTS dsa_problems');
    await db.execute('DROP TABLE IF EXISTS study_materials');
    await db.execute('DROP TABLE IF EXISTS test_history');
    await _createDB(db, newVersion);
  }

  Future _createDB(Database db, int version) async {
    // MCQ Bank — data seeded from Firestore via SyncService
    await db.execute('''
CREATE TABLE IF NOT EXISTS mcq_bank (
  id INTEGER PRIMARY KEY,
  category TEXT NOT NULL,
  question TEXT NOT NULL,
  options TEXT NOT NULL,
  correct_answer_index INTEGER NOT NULL,
  solution TEXT,
  is_bookmarked INTEGER DEFAULT 0
)
''');

    // DSA Problems — id is TEXT because IDs like "dsa_pat1"
    await db.execute('''
CREATE TABLE IF NOT EXISTS dsa_problems (
  id TEXT PRIMARY KEY,
  category TEXT NOT NULL,
  title TEXT NOT NULL,
  difficulty TEXT,
  problem_statement TEXT,
  companies TEXT,
  approach TEXT,
  time_complexity TEXT,
  space_complexity TEXT,
  solutions TEXT,
  step_by_step TEXT,
  is_studied INTEGER DEFAULT 0,
  is_bookmarked INTEGER DEFAULT 0
)
''');

    // Study Materials
    await db.execute('''
CREATE TABLE IF NOT EXISTS study_materials (
  id INTEGER PRIMARY KEY,
  category TEXT NOT NULL,
  content TEXT NOT NULL,
  is_bookmarked INTEGER DEFAULT 0
)
''');

    // Test History
    await db.execute('''
CREATE TABLE IF NOT EXISTS test_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  topic TEXT NOT NULL,
  total_questions INTEGER NOT NULL,
  correct INTEGER NOT NULL,
  wrong INTEGER NOT NULL,
  skipped INTEGER NOT NULL,
  time_taken INTEGER NOT NULL,
  mode TEXT NOT NULL,
  completed_at TEXT NOT NULL
)
''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
