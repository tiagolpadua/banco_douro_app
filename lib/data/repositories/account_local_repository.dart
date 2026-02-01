import 'package:banco_douro_app/data/database/database_helper.dart';
import 'package:banco_douro_app/models/account.dart';
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';

class AccountLocalRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  static const String _tableName = 'accounts';

  Future<int> insert(Account account) async {
    final db = await _dbHelper.database;
    _logger.d("Inserting account locally: ${account.toJson()}");
    final result = await db.insert(
      _tableName,
      _accountToMap(account),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _logger.d("Inserted account with id: ${account.id}");
    return result;
  }

  Future<void> insertAll(List<Account> accounts) async {
    _logger.d("Inserting ${accounts.length} accounts locally...");
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final account in accounts) {
        batch.insert(
          _tableName,
          _accountToMap(account),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<List<Account>> getAll() async {
    _logger.d("Fetching all accounts from local database...");
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'name ASC',
    );

    return maps.map((map) => _accountFromMap(map)).toList();
  }

  Future<int> deleteAll() async {
    final db = await _dbHelper.database;
    return await db.delete(_tableName);
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Map<String, dynamic> _accountToMap(Account account) {
    return {
      'id': account.id,
      'name': account.name,
      'last_name': account.lastName,
      'balance': account.balance,
      'account_type': account.accountType ?? '',
    };
  }

  Account _accountFromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as String,
      name: map['name'] as String,
      lastName: map['last_name'] as String,
      balance: (map['balance'] as num).toDouble(),
      accountType: map['account_type'] as String,
    );
  }
}
