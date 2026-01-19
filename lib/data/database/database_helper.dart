import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

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
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onOpen: _onOpen,
    );
  }

  Future<void> _onOpen(Database db) async {
    print("Database opened: ${db.path}");
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
    print('📦 Migrando banco da versão $oldVersion para $newVersion');

    // Adicione migrações aqui conforme necessário
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE accounts ADD COLUMN phone TEXT');
    // }
  }
}
