import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';

import '../models/account.dart';
import 'http_interceptors.dart';

/// AccountService - Servico de Contas
///
/// Responsavel pela comunicacao com a Web API de contas.
/// Utiliza interceptadores para logging automatico das requisicoes.
class AccountService {
  // URL base da API (10.0.2.2 e o localhost no emulador Android)
  static const String url = "http://10.0.2.2:3000/";
  static const String resource = "accounts/";

  // Cliente HTTP com interceptador de logging
  http.Client client = InterceptedClient.build(
    interceptors: [LoggingInterceptor()],
  );

  String getURL() {
    return "$url$resource";
  }

  Uri getUri() {
    return Uri.parse(getURL());
  }

  /// Busca todas as contas - GET /accounts
  Future<List<Account>> getAll() async {
    http.Response response = await client.get(getUri());

    if (response.statusCode != 200) {
      throw Exception("Falha ao buscar contas: ${response.statusCode}");
    }

    List<Account> result = [];

    List<dynamic> jsonList = json.decode(response.body);
    for (var jsonMap in jsonList) {
      result.add(Account.fromMap(jsonMap));
    }

    return result;
  }

  /// Adiciona uma nova conta - POST /accounts
  Future<bool> addAccount(Account account) async {
    String accountJSON = json.encode(account.toMap());

    http.Response response = await client.post(
      getUri(),
      headers: {'Content-type': 'application/json'},
      body: accountJSON,
    );

    if (response.statusCode == 201) {
      return true;
    }

    return false;
  }
}
