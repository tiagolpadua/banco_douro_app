import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/account.dart';
import 'http_interceptors.dart';

class AccountService {
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  final http.Client _client;

  AccountService()
    : _client = InterceptedClient.build(interceptors: [LoggingInterceptor()]);

  @visibleForTesting
  AccountService.withClient(http.Client client) : _client = client;

  String get _url => ApiConfig.accountsUrl;

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Account>> getAll() async {
    _logger.i("Fetching all accounts from remote server...");

    final headers = await _getHeaders();

    Response response = await _client.get(Uri.parse(_url), headers: headers);

    _logger.i("${DateTime.now()} | Requisicao de leitura.");

    if (response.statusCode != 200) {
      throw Exception("Falha ao buscar contas: ${response.statusCode}");
    }

    List<dynamic> listDynamic = json.decode(response.body);

    List<Account> listAccounts = [];

    for (dynamic dyn in listDynamic) {
      final mapAccount = dyn as Map<String, dynamic>;
      Account account = Account.fromMap(mapAccount);
      listAccounts.add(account);
    }

    return listAccounts;
  }

  Future<bool> addAccount(Account account) async {
    _logger.i("Adding new account to remote server: ${account.toString()}");
    String accountJSON = json.encode(account.toMap());

    final headers = await _getHeaders();
    Response response = await _client.post(
      Uri.parse(_url),
      headers: headers,
      body: accountJSON,
    );

    if (response.statusCode == 201) {
      return true;
    }

    return false;
  }

  Future<bool> updateAccount(Account account) async {
    _logger.i("Updating account on remote server: ${account.id}");
    String accountJSON = json.encode(account.toMap());

    final headers = await _getHeaders();
    Response response = await _client.put(
      Uri.parse('$_url/${account.id}'),
      headers: headers,
      body: accountJSON,
    );

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }

  Future<bool> deleteAccount(String id) async {
    _logger.i("Deleting account from remote server: $id");

    final headers = await _getHeaders();
    Response response = await _client.delete(
      Uri.parse('$_url/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }
}
