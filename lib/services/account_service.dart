import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:logger/logger.dart';

import '../config/api_config.dart';
import '../models/account.dart';
import 'http_interceptors.dart';

class AccountService {
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  final http.Client _client = InterceptedClient.build(
    interceptors: [LoggingInterceptor()],
  );

  String get _url => ApiConfig.accountsUrl;

  Future<List<Account>> getAll() async {
    _logger.i("Fetching all accounts from remote server...");

    Response response = await _client.get(Uri.parse(_url));
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

    Response response = await _client.post(
      Uri.parse(_url),
      headers: {"Content-Type": "application/json"},
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

    Response response = await _client.put(
      Uri.parse('$_url/${account.id}'),
      headers: {"Content-Type": "application/json"},
      body: accountJSON,
    );

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }
}
