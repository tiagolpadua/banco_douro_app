import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:logger/logger.dart';

import '../models/account.dart';
import 'http_interceptors.dart';

class AccountService {
  Logger logger = Logger(printer: PrettyPrinter(methodCount: 0));

  // Cliente HTTP com interceptador de logging
  http.Client client = InterceptedClient.build(
    interceptors: [LoggingInterceptor()],
  );

  String url = "http://10.0.2.2:3000/accounts";

  Future<List<Account>> getAll() async {
    logger.i("Fetching all accounts from remote server...");

    Response response = await client.get(Uri.parse(url));
    // Response response = await get(Uri.parse(url));
    logger.i("${DateTime.now()} | Requisição de leitura.");

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
    logger.i("Adding new account to remote server: ${account.toString()}");
    String accountJSON = json.encode(account.toMap());

    Response response = await client.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: accountJSON,
    );

    if (response.statusCode == 201) {
      return true;
    }

    return false;
  }

  save(List<Account> listAccounts, {String accountName = ""}) async {
    // Implementação removida - usar addAccount para adicionar contas individuais
    logger.i("${DateTime.now()} | Método save depreciado.");
  }
}
