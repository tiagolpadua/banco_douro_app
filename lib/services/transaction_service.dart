import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart';

import '../exceptions/transaction_exceptions.dart';
import '../helpers/helper_taxes.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import 'account_service.dart';

class TransactionService {
  final AccountService _accountService = AccountService();
  String url = "http://10.0.2.2:3000/transactions";

  Future<void> makeTransaction({
    required String idSender,
    required String idReceiver,
    required double amount,
  }) async {
    List<Account> listAccounts = await _accountService.getAll();

    if (listAccounts.where((acc) => acc.id == idSender).isEmpty) {
      throw SenderNotExistsException();
    }

    Account senderAccount = listAccounts.firstWhere(
      (acc) => acc.id == idSender,
    );

    if (listAccounts.where((acc) => acc.id == idReceiver).isEmpty) {
      throw ReceiverNotExistsException();
    }

    Account receiverAccount = listAccounts.firstWhere(
      (acc) => acc.id == idReceiver,
    );

    double taxes = calculateTaxesByAccount(
      sender: senderAccount,
      amount: amount,
    );

    if (senderAccount.balance < amount + taxes) {
      throw InsufficientFundsException(
        cause: senderAccount,
        amount: amount,
        taxes: taxes,
      );
    }

    senderAccount.balance -= (amount + taxes);
    receiverAccount.balance += amount;

    listAccounts[listAccounts.indexWhere((acc) => acc.id == senderAccount.id)] =
        senderAccount;

    listAccounts[listAccounts.indexWhere(
          (acc) => acc.id == receiverAccount.id,
        )] =
        receiverAccount;

    Transaction transaction = Transaction(
      id: (Random().nextInt(89999) + 10000).toString(),
      senderAccountId: senderAccount.id,
      receiverAccountId: receiverAccount.id,
      date: DateTime.now(),
      amount: amount,
      taxes: taxes,
    );

    await _accountService.save(listAccounts);
    await addTransaction(transaction);
  }

  Future<List<Transaction>> getAll() async {
    Response response = await get(Uri.parse(url));

    List<dynamic> listDynamic = json.decode(response.body);

    List<Transaction> listTransactions = [];

    for (dynamic dyn in listDynamic) {
      Map<String, dynamic> mapTrans = dyn as Map<String, dynamic>;
      Transaction transaction = Transaction.fromMap(mapTrans);
      listTransactions.add(transaction);
    }

    return listTransactions;
  }

  Future<void> addTransaction(Transaction trans) async {
    await post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode(trans.toMap()),
    );
  }

  Future<void> save(List<Transaction> listTransactions) async {
    // Método depreciado - usar addTransaction para adicionar transações individuais
  }
}
