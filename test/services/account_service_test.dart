import 'dart:convert';

import 'package:banco_douro_app/models/account.dart';
import 'package:banco_douro_app/services/account_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final fakeAccount = Account(
    id: '1',
    name: 'João',
    lastName: 'Silva',
    balance: 1000,
    accountType: 'PUDIM',
  );

  final fakeAccountsJson = json.encode([
    {'id': '1', 'name': 'João', 'lastName': 'Silva', 'balance': 1000.0, 'accountType': 'PUDIM'},
    {'id': '2', 'name': 'Maria', 'lastName': 'Costa', 'balance': 5000.0, 'accountType': 'BRIGADEIRO'},
  ]);

  setUp(() {
    SharedPreferences.setMockInitialValues({'accessToken': 'fake-token'});
  });

  group('AccountService.getAll', () {
    test('retorna lista de contas quando status 200', () async {
      final client = MockClient((_) async => http.Response(fakeAccountsJson, 200));
      final service = AccountService.withClient(client);

      final accounts = await service.getAll();

      expect(accounts.length, 2);
      expect(accounts[0].id, '1');
      expect(accounts[0].name, 'João');
      expect(accounts[1].id, '2');
    });

    test('retorna lista vazia quando body é []', () async {
      final client = MockClient((_) async => http.Response('[]', 200));
      final service = AccountService.withClient(client);

      final accounts = await service.getAll();

      expect(accounts, isEmpty);
    });

    test('lança Exception quando status != 200', () async {
      final client = MockClient((_) async => http.Response('Unauthorized', 401));
      final service = AccountService.withClient(client);

      expect(() => service.getAll(), throwsException);
    });

    test('lança Exception quando status 500', () async {
      final client = MockClient((_) async => http.Response('Internal Server Error', 500));
      final service = AccountService.withClient(client);

      expect(() => service.getAll(), throwsException);
    });

    test('envia header Authorization com token correto', () async {
      String? capturedAuth;
      final client = MockClient((request) async {
        capturedAuth = request.headers['Authorization'];
        return http.Response(fakeAccountsJson, 200);
      });
      final service = AccountService.withClient(client);

      await service.getAll();

      expect(capturedAuth, 'Bearer fake-token');
    });
  });

  group('AccountService.addAccount', () {
    test('retorna true quando status 201', () async {
      final client = MockClient((_) async => http.Response('{}', 201));
      final service = AccountService.withClient(client);

      final result = await service.addAccount(fakeAccount);

      expect(result, true);
    });

    test('retorna false quando status != 201', () async {
      final client = MockClient((_) async => http.Response('Bad Request', 400));
      final service = AccountService.withClient(client);

      final result = await service.addAccount(fakeAccount);

      expect(result, false);
    });

    test('retorna false quando status 500', () async {
      final client = MockClient((_) async => http.Response('Error', 500));
      final service = AccountService.withClient(client);

      final result = await service.addAccount(fakeAccount);

      expect(result, false);
    });

    test('envia body JSON correto', () async {
      String? capturedBody;
      final client = MockClient((request) async {
        capturedBody = request.body;
        return http.Response('{}', 201);
      });
      final service = AccountService.withClient(client);

      await service.addAccount(fakeAccount);

      final decoded = json.decode(capturedBody!);
      expect(decoded['id'], '1');
      expect(decoded['name'], 'João');
      expect(decoded['lastName'], 'Silva');
      expect(decoded['balance'], 1000.0);
      expect(decoded['accountType'], 'PUDIM');
    });

    test('envia header Authorization correto', () async {
      String? capturedAuth;
      final client = MockClient((request) async {
        capturedAuth = request.headers['Authorization'];
        return http.Response('{}', 201);
      });
      final service = AccountService.withClient(client);

      await service.addAccount(fakeAccount);

      expect(capturedAuth, 'Bearer fake-token');
    });
  });

  group('AccountService.updateAccount', () {
    test('retorna true quando status 200', () async {
      final client = MockClient((_) async => http.Response('{}', 200));
      final service = AccountService.withClient(client);

      final result = await service.updateAccount(fakeAccount);

      expect(result, true);
    });

    test('retorna false quando status != 200', () async {
      final client = MockClient((_) async => http.Response('Not Found', 404));
      final service = AccountService.withClient(client);

      final result = await service.updateAccount(fakeAccount);

      expect(result, false);
    });

    test('faz PUT para URL com id correto', () async {
      Uri? capturedUri;
      final client = MockClient((request) async {
        capturedUri = request.url;
        return http.Response('{}', 200);
      });
      final service = AccountService.withClient(client);

      await service.updateAccount(fakeAccount);

      expect(capturedUri?.path, endsWith('/accounts/1'));
    });

    test('envia body JSON correto', () async {
      String? capturedBody;
      final client = MockClient((request) async {
        capturedBody = request.body;
        return http.Response('{}', 200);
      });
      final service = AccountService.withClient(client);

      await service.updateAccount(fakeAccount);

      final decoded = json.decode(capturedBody!);
      expect(decoded['id'], '1');
      expect(decoded['balance'], 1000.0);
    });
  });

  group('AccountService.deleteAccount', () {
    test('retorna true quando status 200', () async {
      final client = MockClient((_) async => http.Response('{}', 200));
      final service = AccountService.withClient(client);

      final result = await service.deleteAccount('1');

      expect(result, true);
    });

    test('retorna false quando status != 200', () async {
      final client = MockClient((_) async => http.Response('Not Found', 404));
      final service = AccountService.withClient(client);

      final result = await service.deleteAccount('1');

      expect(result, false);
    });

    test('retorna false quando status 500', () async {
      final client = MockClient((_) async => http.Response('Error', 500));
      final service = AccountService.withClient(client);

      final result = await service.deleteAccount('1');

      expect(result, false);
    });

    test('faz DELETE para URL com id correto', () async {
      Uri? capturedUri;
      String? capturedMethod;
      final client = MockClient((request) async {
        capturedUri = request.url;
        capturedMethod = request.method;
        return http.Response('{}', 200);
      });
      final service = AccountService.withClient(client);

      await service.deleteAccount('42');

      expect(capturedMethod, 'DELETE');
      expect(capturedUri?.path, endsWith('/accounts/42'));
    });

    test('envia header Authorization correto', () async {
      String? capturedAuth;
      final client = MockClient((request) async {
        capturedAuth = request.headers['Authorization'];
        return http.Response('{}', 200);
      });
      final service = AccountService.withClient(client);

      await service.deleteAccount('1');

      expect(capturedAuth, 'Bearer fake-token');
    });
  });
}
