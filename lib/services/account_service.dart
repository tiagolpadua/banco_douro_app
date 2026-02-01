import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../exceptions/api_exceptions.dart';
import '../models/account.dart';
import 'http_interceptors.dart';

class AccountService {
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  final http.Client _client = InterceptedClient.build(
    interceptors: [LoggingInterceptor()],
  );

  String get _url => ApiConfig.accountsUrl;

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  void _verifyException(String responseBody) {
    final errorMessage = responseBody.toLowerCase();

    if (errorMessage.contains('jwt expired')) {
      throw TokenExpiredException();
    }
    if (errorMessage.contains('jwt malformed') ||
        errorMessage.contains('unauthorized')) {
      throw UnauthorizedException();
    }
    if (errorMessage.contains('not found')) {
      throw NotFoundException();
    }

    throw ServerException(responseBody);
  }

  Future<List<Account>> getAll() async {
    _logger.i("Fetching all accounts from remote server...");

    final headers = await _getHeaders();
    Response response = await _client.get(
      Uri.parse(_url),
      headers: headers,
    );
    _logger.i("${DateTime.now()} | Requisicao de leitura.");

    if (response.statusCode != 200) {
      _verifyException(response.body);
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

    _verifyException(response.body);
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

    _verifyException(response.body);
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

    _verifyException(response.body);
    return false;
  }
}
