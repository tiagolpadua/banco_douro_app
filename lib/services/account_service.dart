import 'dart:async';

import 'package:http/http.dart';
import 'dart:convert';

import '../models/account.dart';

class AccountService {
  final StreamController<String> _streamController = StreamController<String>();
  Stream<String> get streamInfos => _streamController.stream;

  String url = "http://10.0.2.2:3000/accounts";

  AccountService() {
    _streamController.stream.listen((message) {
      print(message);
    });
  }

  Future<List<Account>> getAll() async {
    print("Fetching all accounts from remote server...");
    // try {
    await Future.delayed(Duration(seconds: 1));

    Response response = await get(Uri.parse(url));
    _streamController.add("${DateTime.now()} | Requisição de leitura.");

    List<dynamic> listDynamic = json.decode(response.body);

    List<Account> listAccounts = [];

    for (dynamic dyn in listDynamic) {
      final mapAccount = dyn as Map<String, dynamic>;
      Account account = Account.fromMap(mapAccount);
      listAccounts.add(account);
    }

    return listAccounts;
    // } catch (e) {
    //   _streamController.add(
    //     "${DateTime.now()} | Erro na requisição de leitura: $e",
    //   );
    //   return [];
    // }
  }

  addAccount(Account account) async {
    Response response = await post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode(account.toMap()),
    );

    if (response.statusCode.toString()[0] == "2") {
      _streamController.add(
        "${DateTime.now()} | Requisição adição bem sucedida (${account.name}).",
      );
    } else {
      _streamController.add(
        "${DateTime.now()} | Requisição falhou (${account.name}).",
      );
    }
  }

  save(List<Account> listAccounts, {String accountName = ""}) async {
    // Implementação removida - usar addAccount para adicionar contas individuais
    _streamController.add("${DateTime.now()} | Método save depreciado.");
  }
}
