import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';

import '../models/account_type.dart';
import 'http_interceptors.dart';

/// AccountTypeService - Servico de Tipos de Conta
///
/// Responsavel pela comunicacao com a Web API de tipos de conta.
/// Utiliza interceptadores para logging automatico das requisicoes.
class AccountTypeService {
  // URL base da API (10.0.2.2 e o localhost no emulador Android)
  static const String url = "http://10.0.2.2:3000/";
  static const String resource = "accountTypes/";

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

  /// Busca todos os tipos de conta - GET /accountTypes
  Future<List<AccountType>> getAll() async {
    http.Response response = await client.get(getUri());

    if (response.statusCode != 200) {
      throw Exception("Falha ao buscar tipos de conta: ${response.statusCode}");
    }

    List<AccountType> result = [];

    List<dynamic> jsonList = json.decode(response.body);
    for (var jsonMap in jsonList) {
      result.add(AccountType.fromMap(jsonMap));
    }

    return result;
  }

  /// Busca um tipo de conta por ID - GET /accountTypes/:id
  Future<AccountType?> getById(String id) async {
    http.Response response = await client.get(
      Uri.parse("${getURL()}$id"),
    );

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode != 200) {
      throw Exception("Falha ao buscar tipo de conta: ${response.statusCode}");
    }

    Map<String, dynamic> jsonMap = json.decode(response.body);
    return AccountType.fromMap(jsonMap);
  }
}
