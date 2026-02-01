import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  static Database? _database;

  DatabaseHelper._init();

  /// Obtém a instância do banco de dados.
  /// Cria o banco se não existir.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static const String _databaseName = 'banco_douro.db';

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onOpen: _onOpen,
    );
  }

  Future<void> _onOpen(Database db) async {
    _logger.i("Database opened: ${db.path}");
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE accounts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        balance REAL DEFAULT 0,
        account_type TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        sender_account_id TEXT NOT NULL,
        receiver_account_id TEXT NOT NULL,
        date INTEGER NOT NULL,
        amount REAL NOT NULL,
        taxes REAL NOT NULL
      )
    ''');
  }

  /// Migra o banco para versões mais novas
  ///
  /// Exemplo de migração:
  /// ```dart
  /// if (oldVersion < 2) {
  ///   await db.execute('ALTER TABLE accounts ADD COLUMN phone TEXT');
  /// }
  /// if (oldVersion < 3) {
  ///   await db.execute('ALTER TABLE accounts ADD COLUMN email TEXT');
  /// }
  /// ```
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    _logger.i('Migrando banco da versao $oldVersion para $newVersion');

    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE transactions (
          id TEXT PRIMARY KEY,
          sender_account_id TEXT NOT NULL,
          receiver_account_id TEXT NOT NULL,
          date INTEGER NOT NULL,
          amount REAL NOT NULL,
          taxes REAL NOT NULL
        )
      ''');
    }
  }
}
