import 'package:flutter_test/flutter_test.dart';
import 'package:banco_douro_app/helpers/helper_taxes.dart';
import 'package:banco_douro_app/models/account.dart';

void main() {
  Account makeAccount({String? type = 'PUDIM', double balance = 10000}) {
    return Account(
      id: '1',
      name: 'Teste',
      lastName: 'Conta',
      balance: balance,
      accountType: type,
    );
  }

  group('TaxConfig', () {
    test('minimumTaxableAmount deve ser 5000', () {
      expect(TaxConfig.minimumTaxableAmount, 5000.0);
    });

    test('taxRates deve conter os 4 tipos de conta', () {
      expect(TaxConfig.taxRates.containsKey('AMBROSIA'), isTrue);
      expect(TaxConfig.taxRates.containsKey('CANJICA'), isTrue);
      expect(TaxConfig.taxRates.containsKey('PUDIM'), isTrue);
      expect(TaxConfig.taxRates.containsKey('BRIGADEIRO'), isTrue);
    });

    test('taxa AMBROSIA deve ser 0.5%', () {
      expect(TaxConfig.taxRates['AMBROSIA'], 0.005);
    });

    test('taxa CANJICA deve ser 0.33%', () {
      expect(TaxConfig.taxRates['CANJICA'], 0.0033);
    });

    test('taxa PUDIM deve ser 0.25%', () {
      expect(TaxConfig.taxRates['PUDIM'], 0.0025);
    });

    test('taxa BRIGADEIRO deve ser 0.01%', () {
      expect(TaxConfig.taxRates['BRIGADEIRO'], 0.0001);
    });
  });

  group('calculateTaxesByAccount — abaixo do mínimo tributável', () {
    test('deve retornar 0 para amount = 4999.99', () {
      final account = makeAccount(type: 'PUDIM');
      final taxes = calculateTaxesByAccount(sender: account, amount: 4999.99);
      expect(taxes, 0.0);
    });

    test('deve retornar 0 para amount = 0', () {
      final account = makeAccount(type: 'BRIGADEIRO');
      final taxes = calculateTaxesByAccount(sender: account, amount: 0);
      expect(taxes, 0.0);
    });

    test('deve retornar 0 para amount = 1', () {
      final account = makeAccount(type: 'AMBROSIA');
      final taxes = calculateTaxesByAccount(sender: account, amount: 1);
      expect(taxes, 0.0);
    });
  });

  group('calculateTaxesByAccount — AMBROSIA (0.5%)', () {
    test('deve aplicar 0.5% para amount exato de 5000', () {
      final account = makeAccount(type: 'AMBROSIA');
      final taxes = calculateTaxesByAccount(sender: account, amount: 5000);
      expect(taxes, closeTo(25.0, 0.001));
    });

    test('deve aplicar 0.5% para amount = 10000', () {
      final account = makeAccount(type: 'AMBROSIA');
      final taxes = calculateTaxesByAccount(sender: account, amount: 10000);
      expect(taxes, closeTo(50.0, 0.001));
    });
  });

  group('calculateTaxesByAccount — CANJICA (0.33%)', () {
    test('deve aplicar 0.33% para amount = 5000', () {
      final account = makeAccount(type: 'CANJICA');
      final taxes = calculateTaxesByAccount(sender: account, amount: 5000);
      expect(taxes, closeTo(16.5, 0.001));
    });
  });

  group('calculateTaxesByAccount — PUDIM (0.25%)', () {
    test('deve aplicar 0.25% para amount = 5000', () {
      final account = makeAccount(type: 'PUDIM');
      final taxes = calculateTaxesByAccount(sender: account, amount: 5000);
      expect(taxes, closeTo(12.5, 0.001));
    });

    test('deve aplicar 0.25% para amount = 8000', () {
      final account = makeAccount(type: 'PUDIM');
      final taxes = calculateTaxesByAccount(sender: account, amount: 8000);
      expect(taxes, closeTo(20.0, 0.001));
    });
  });

  group('calculateTaxesByAccount — BRIGADEIRO (0.01%)', () {
    test('deve aplicar 0.01% para amount = 5000', () {
      final account = makeAccount(type: 'BRIGADEIRO');
      final taxes = calculateTaxesByAccount(sender: account, amount: 5000);
      expect(taxes, closeTo(0.5, 0.001));
    });

    test('deve aplicar 0.01% para amount = 100000', () {
      final account = makeAccount(type: 'BRIGADEIRO');
      final taxes = calculateTaxesByAccount(sender: account, amount: 100000);
      expect(taxes, closeTo(10.0, 0.001));
    });
  });

  group('calculateTaxesByAccount — tipo desconhecido / nulo', () {
    test('deve usar taxa BRIGADEIRO para tipo desconhecido (fallback)', () {
      final account = makeAccount(type: 'INEXISTENTE');
      final taxes = calculateTaxesByAccount(sender: account, amount: 5000);
      // Conforme implementação: usa taxRates['BRIGADEIRO'] como fallback
      expect(taxes, closeTo(5000 * 0.0001, 0.001));
    });

    test('deve retornar defaultTaxRate quando accountType é null', () {
      final account = makeAccount(type: null);
      final taxes = calculateTaxesByAccount(sender: account, amount: 5000);
      expect(taxes, TaxConfig.defaultTaxRate);
    });
  });
}
