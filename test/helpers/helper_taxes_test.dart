import 'package:banco_douro_app/helpers/helper_taxes.dart';
import 'package:banco_douro_app/models/account.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Account makeAccount({String type = 'PUDIM', double balance = 10000}) {
    return Account(
      id: '1',
      name: 'Teste',
      lastName: 'Conta',
      balance: balance,
      accountType: type,
    );
  }

  group('valor abaixo do mínimo tributável', () {
    test('retorna 0 para amount = 4999', () {
      final account = makeAccount(type: 'PUDIM');
      expect(calculateTaxesByAccount(sender: account, amount: 4999), 0.0);
    });

    test('retorna 0 para amount = 0', () {
      final account = makeAccount(type: 'BRIGADEIRO');
      expect(calculateTaxesByAccount(sender: account, amount: 0), 0.0);
    });
  });

  group('tipos de conta com imposto correto', () {
    test('AMBROSIA aplica 0.5% para 5000', () {
      final account = makeAccount(type: 'AMBROSIA');
      final tax = calculateTaxesByAccount(sender: account, amount: 5000);
      expect(tax, closeTo(25.0, 0.001));
    });

    test('CANJICA aplica 0.33% para 5000', () {
      final account = makeAccount(type: 'CANJICA');
      final tax = calculateTaxesByAccount(sender: account, amount: 5000);
      expect(tax, closeTo(16.5, 0.001));
    });

    test('PUDIM aplica 0.25% para 5000', () {
      final account = makeAccount(type: 'PUDIM');
      final tax = calculateTaxesByAccount(sender: account, amount: 5000);
      expect(tax, closeTo(12.5, 0.001));
    });

    test('BRIGADEIRO aplica 0.01% para 5000', () {
      final account = makeAccount(type: 'BRIGADEIRO');
      final tax = calculateTaxesByAccount(sender: account, amount: 5000);
      expect(tax, closeTo(0.5, 0.001));
    });
  });

  test('tipo desconhecido usa taxa padrão', () {
    final account = makeAccount(type: 'INEXISTENTE');
    expect(calculateTaxesByAccount(sender: account, amount: 5000), 0.5);
  });
}
