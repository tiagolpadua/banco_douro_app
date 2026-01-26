import 'package:banco_douro_app/data/database/database_helper.dart';
import 'package:banco_douro_app/models/account.dart';
import 'package:flutter/rendering.dart';
import 'package:sqflite/sqflite.dart';

class AccountLocalRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  static const String _tableName = 'accounts';

  Future<int> insert(Account account) async {
    final db = await _dbHelper.database;
    debugPrint("Inserting account locally: ${account.toJson()}");
    final result = await db.insert(
      _tableName,
      _accountToMap(account),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint("Inserted account with id: ${account.id}");
    return result;
  }

  Future<void> insertAll(List<Account> accounts) async {
    debugPrint("Inserting ${accounts.length} accounts locally...");
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
    debugPrint("Fetching all accounts from local database...");
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'name ASC',
    );

    return maps.map((map) => _accountFromMap(map)).toList();
  }

  /// Busca contas por nome (busca parcial, case-insensitive).
  Future<List<Account>> searchByName(String query) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'name LIKE ? OR last_name LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
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
      'account_type_id': account.accountTypeId,
    };
  }

  Account _accountFromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as String,
      name: map['name'] as String,
      lastName: map['last_name'] as String,
      balance: (map['balance'] as num).toDouble(),
      accountTypeId: map['account_type_id'] as String?,
    );
  }
}
