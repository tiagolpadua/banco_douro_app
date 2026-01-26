import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';

import '../models/account_type.dart';
import 'http_interceptors.dart';

class AccountTypeService {
  static const String url = "http://10.0.2.2:3000/";
  static const String resource = "accountTypes";

  http.Client client = InterceptedClient.build(
    interceptors: [LoggingInterceptor()],
  );

  String getURL() {
    return "$url$resource";
  }

  Uri getUri() {
    return Uri.parse(getURL());
  }

  Future<List<AccountType>> getAll() async {
    http.Response response = await client.get(getUri());

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
