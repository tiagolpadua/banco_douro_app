import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';

import '../config/api_config.dart';
import '../models/account_type.dart';
import 'http_interceptors.dart';

class AccountTypeService {
  final http.Client _client = InterceptedClient.build(
    interceptors: [LoggingInterceptor()],
  );

  Uri get _uri => Uri.parse(ApiConfig.accountTypesUrl);

  Future<List<AccountType>> getAll() async {
    http.Response response = await _client.get(_uri);

    if (response.statusCode != 200) {
      throw Exception("Falha ao buscar tipos de conta: ${response.statusCode}");
    }

    List<AccountType> accountTypes = [];

    List<dynamic> jsonList = json.decode(response.body);
    for (var jsonMap in jsonList) {
      accountTypes.add(AccountType.fromMap(jsonMap));
    }

    return accountTypes;
  }
}
