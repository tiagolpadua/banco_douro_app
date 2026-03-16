import 'package:flutter_test/flutter_test.dart';
import 'package:banco_douro_app/helpers/helper_taxes.dart';
import 'package:banco_douro_app/exceptions/transaction_exceptions.dart';
import 'package:banco_douro_app/models/account.dart';

void main() {
  group('validateTransaction', () {
    final account = Account(
      id: '1',
      name: 'João',
      lastName: 'Silva',
      balance: 5000,
      accountType: 'PUDIM',
    );

    test('deve lançar InsufficientFundsException quando saldo é insuficiente', () {
      // Saldo = 5000, transferência = 5000, imposto PUDIM 0.25% = 12.5
      // Total necessário = 5012.5 > 5000 → deve lançar exceção
      expect(
        () => validateTransaction(sender: account, amount: 5000),
        throwsA(isA<InsufficientFundsException>()),
      );
    });

    test('deve permitir transferência quando saldo cobre valor + imposto', () {
      // Saldo = 5000, transferência = 4900, abaixo do limite → imposto = 0
      // Total necessário = 4900 < 5000 → deve passar
      expect(
        () => validateTransaction(sender: account, amount: 4900),
        returnsNormally,
      );
    });

    test('deve lançar ArgumentError para valor negativo', () {
      expect(
        () => validateTransaction(sender: account, amount: -100),
        throwsArgumentError,
      );
    });

    test('deve lançar ArgumentError para valor zero', () {
      expect(
        () => validateTransaction(sender: account, amount: 0),
        throwsArgumentError,
      );
    });
  });
}
