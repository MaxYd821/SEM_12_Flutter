import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'Ticket.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tickets.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tickets (
        id TEXT PRIMARY KEY,
        summary TEXT,
        description TEXT,
        projectKey TEXT
      )
    ''');
  }

  Future<void> insertTicket(Ticket ticket) async {
    final db = await instance.database;
    await db.insert('tickets', ticket.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Ticket>> getTicketsByProject(String projectKey) async {
    final db = await instance.database;
    final result = await db.query(
      'tickets',
      where: 'projectKey = ?',
      whereArgs: [projectKey],
    );
    return result.map((map) => Ticket.fromMap(map)).toList();
  }

  Future<void> clearTickets() async {
    final db = await instance.database;
    await db.delete('tickets');
  }
}
