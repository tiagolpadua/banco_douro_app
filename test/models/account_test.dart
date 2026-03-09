import 'package:flutter_test/flutter_test.dart';
import 'package:banco_douro_app/models/account.dart';

void main() {
  final accountMap = <String, dynamic>{
    'id': 'abc-123',
    'name': 'Maria',
    'lastName': 'Oliveira',
    'balance': 2500.0,
    'accountType': 'PUDIM',
  };

  group('Account.fromMap', () {
    test('deve criar Account com todos os campos corretos', () {
      final account = Account.fromMap(accountMap);

      expect(account.id, 'abc-123');
      expect(account.name, 'Maria');
      expect(account.lastName, 'Oliveira');
      expect(account.balance, 2500.0);
      expect(account.accountType, 'PUDIM');
    });

    test('deve converter balance int para double', () {
      final mapWithIntBalance = {...accountMap, 'balance': 1000};
      final account = Account.fromMap(mapWithIntBalance);

      expect(account.balance, isA<double>());
      expect(account.balance, 1000.0);
    });

    test('deve aceitar accountType nulo', () {
      final mapWithNullType = {...accountMap, 'accountType': null};
      final account = Account.fromMap(mapWithNullType);

      expect(account.accountType, isNull);
    });

    test('deve converter id numérico para String', () {
      final mapWithIntId = {...accountMap, 'id': 42};
      final account = Account.fromMap(mapWithIntId);

      expect(account.id, '42');
    });
  });

  group('Account.toMap', () {
    test('deve converter Account para Map com todos os campos', () {
      final account = Account.fromMap(accountMap);
      final map = account.toMap();

      expect(map['id'], 'abc-123');
      expect(map['name'], 'Maria');
      expect(map['lastName'], 'Oliveira');
      expect(map['balance'], 2500.0);
      expect(map['accountType'], 'PUDIM');
    });

    test('fromMap e toMap devem ser inversos', () {
      final account = Account.fromMap(accountMap);
      final map = account.toMap();
      final accountRecriado = Account.fromMap(map);

      expect(accountRecriado.id, account.id);
      expect(accountRecriado.name, account.name);
      expect(accountRecriado.balance, account.balance);
    });
  });

  group('Account.toJson / fromJson', () {
    test('deve serializar e desserializar corretamente', () {
      final account = Account.fromMap(accountMap);
      final json = account.toJson();
      final accountFromJson = Account.fromJson(json);

      expect(accountFromJson.id, account.id);
      expect(accountFromJson.name, account.name);
      expect(accountFromJson.balance, account.balance);
      expect(accountFromJson.accountType, account.accountType);
    });
  });

  group('Account.copyWith', () {
    test('deve criar cópia alterando apenas os campos especificados', () {
      final original = Account.fromMap(accountMap);
      final copia = original.copyWith(balance: 9000.0, name: 'Ana');

      expect(copia.id, original.id);
      expect(copia.lastName, original.lastName);
      expect(copia.accountType, original.accountType);
      expect(copia.balance, 9000.0);
      expect(copia.name, 'Ana');
    });

    test('deve manter todos os campos quando nenhum é especificado', () {
      final original = Account.fromMap(accountMap);
      final copia = original.copyWith();

      expect(copia.id, original.id);
      expect(copia.name, original.name);
      expect(copia.lastName, original.lastName);
      expect(copia.balance, original.balance);
      expect(copia.accountType, original.accountType);
    });

    test('não deve alterar o objeto original', () {
      final original = Account.fromMap(accountMap);
      original.copyWith(balance: 99999.0);

      expect(original.balance, 2500.0);
    });

    test('deve retornar um objeto diferente (não a mesma referência)', () {
      final original = Account.fromMap(accountMap);
      final copia = original.copyWith();

      expect(identical(original, copia), isFalse);
    });
  });

  group('Account equality (== e hashCode)', () {
    test('contas com mesmos dados devem ser iguais', () {
      final a1 = Account.fromMap(accountMap);
      final a2 = Account.fromMap(accountMap);

      expect(a1, equals(a2));
    });

    test('contas com id diferente não devem ser iguais', () {
      final a1 = Account.fromMap(accountMap);
      final a2 = Account.fromMap({...accountMap, 'id': 'outro-id'});

      expect(a1, isNot(equals(a2)));
    });

    test('conta idêntica a si mesma deve ser igual', () {
      final a1 = Account.fromMap(accountMap);

      expect(a1, equals(a1));
    });

    test('hashCode deve ser consistente para o mesmo objeto', () {
      final account = Account.fromMap(accountMap);

      expect(account.hashCode, equals(account.hashCode));
    });

    test('objetos iguais devem ter o mesmo hashCode', () {
      final a1 = Account.fromMap(accountMap);
      final a2 = Account.fromMap(accountMap);

      expect(a1.hashCode, equals(a2.hashCode));
    });
  });

  group('Account.toString', () {
    test('deve incluir os campos principais', () {
      final account = Account.fromMap(accountMap);
      final str = account.toString();

      expect(str, contains('abc-123'));
      expect(str, contains('Maria'));
      expect(str, contains('2500'));
    });
  });
}
