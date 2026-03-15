import 'package:banco_douro_app/models/account.dart';
import 'package:banco_douro_app/models/account_type.dart';
import 'package:banco_douro_app/providers/account_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';

void main() {
  late MockAccountService mockService;
  late MockAccountTypeService mockTypeService;
  late MockAccountLocalRepository mockRepo;
  late AccountProvider provider;

  final fakeAccounts = [
    Account(id: '1', name: 'João', lastName: 'Silva', balance: 1000, accountType: 'PUDIM'),
    Account(id: '2', name: 'Maria', lastName: 'Costa', balance: 5000, accountType: 'BRIGADEIRO'),
  ];

  final fakeTypes = [
    AccountType(id: 'PUDIM', description: 'Conta Pudim'),
    AccountType(id: 'BRIGADEIRO', description: 'Conta Brigadeiro'),
  ];

  setUp(() {
    mockService = MockAccountService();
    mockTypeService = MockAccountTypeService();
    mockRepo = MockAccountLocalRepository();
    provider = AccountProvider(
      accountService: mockService,
      accountTypeService: mockTypeService,
      accountLocalRepository: mockRepo,
    );
  });

  // Stubs para as operações de cache do repo (necessárias em loadAll)
  void stubRepoCache() {
    when(mockRepo.deleteAll()).thenAnswer((_) async => 0);
    when(mockRepo.insertAll(any)).thenAnswer((_) async {});
  }

  group('AccountProvider.loadAll', () {
    test('carrega contas com sucesso e atualiza lista', () async {
      when(mockService.getAll()).thenAnswer((_) async => fakeAccounts);
      stubRepoCache();

      await provider.loadAll();

      expect(provider.accounts.length, 2);
      expect(provider.error, isNull);
      expect(provider.isLoading, false);
    });

    test('isLoading é true durante o carregamento', () async {
      bool wasLoading = false;

      when(mockService.getAll()).thenAnswer((_) async {
        wasLoading = provider.isLoading;
        return fakeAccounts;
      });
      stubRepoCache();

      await provider.loadAll();

      expect(wasLoading, true);
      expect(provider.isLoading, false);
    });

    test('define error e usa cache local quando API falha', () async {
      when(mockService.getAll()).thenThrow(Exception('Sem conexão'));
      when(mockRepo.getAll()).thenAnswer((_) async => fakeAccounts);

      await provider.loadAll();

      expect(provider.error, isNotNull);
      expect(provider.accounts.length, 2);
    });

    test('atualiza cache local após carregar da API', () async {
      when(mockService.getAll()).thenAnswer((_) async => fakeAccounts);
      stubRepoCache();

      await provider.loadAll();

      verify(mockRepo.deleteAll()).called(1);
      verify(mockRepo.insertAll(fakeAccounts)).called(1);
    });
  });

  group('AccountProvider.loadAccountTypes', () {
    test('carrega tipos de conta com sucesso', () async {
      when(mockTypeService.getAll()).thenAnswer((_) async => fakeTypes);

      await provider.loadAccountTypes();

      expect(provider.accountTypes.length, 2);
      expect(provider.isLoadingAccountTypes, false);
    });

    test('define lista vazia quando API de tipos falha', () async {
      when(mockTypeService.getAll()).thenThrow(Exception('Erro'));

      await provider.loadAccountTypes();

      expect(provider.accountTypes, isEmpty);
      expect(provider.isLoadingAccountTypes, false);
    });
  });

  group('AccountProvider.addAccount', () {
    final novaAccount = Account(
      id: '3',
      name: 'Carlos',
      lastName: 'Lima',
      balance: 2000,
      accountType: 'CANJICA',
    );

    setUp(() {
      when(mockService.getAll()).thenAnswer((_) async => fakeAccounts);
      stubRepoCache();
    });

    test('adiciona conta à lista após sucesso na API', () async {
      when(mockService.addAccount(novaAccount)).thenAnswer((_) async => true);
      when(mockRepo.insert(novaAccount)).thenAnswer((_) async => 1);

      await provider.loadAll();
      await provider.addAccount(novaAccount);

      expect(provider.accounts.length, 3);
      expect(provider.accounts.any((a) => a.id == '3'), true);
    });

    test('salva conta no cache local após sucesso na API', () async {
      when(mockService.addAccount(novaAccount)).thenAnswer((_) async => true);
      when(mockRepo.insert(novaAccount)).thenAnswer((_) async => 1);

      await provider.loadAll();
      await provider.addAccount(novaAccount);

      verify(mockRepo.insert(novaAccount)).called(1);
    });

    test('lança exceção e não modifica lista quando API retorna false', () async {
      when(mockService.addAccount(novaAccount)).thenAnswer((_) async => false);

      await provider.loadAll();
      final countAntes = provider.accounts.length;

      expect(
        () => provider.addAccount(novaAccount),
        throwsException,
      );
      expect(provider.accounts.length, countAntes);
    });
  });

  group('AccountProvider.deleteAccount', () {
    setUp(() async {
      when(mockService.getAll()).thenAnswer((_) async => fakeAccounts);
      stubRepoCache();
      await provider.loadAll();
    });

    test('remove conta da lista após sucesso na API', () async {
      when(mockService.deleteAccount('1')).thenAnswer((_) async => true);
      when(mockRepo.delete('1')).thenAnswer((_) async => 1);

      await provider.deleteAccount('1');

      expect(provider.accounts.any((a) => a.id == '1'), false);
      expect(provider.accounts.length, 1);
    });

    test('remove conta do cache local após sucesso na API', () async {
      when(mockService.deleteAccount('1')).thenAnswer((_) async => true);
      when(mockRepo.delete('1')).thenAnswer((_) async => 1);

      await provider.deleteAccount('1');

      verify(mockRepo.delete('1')).called(1);
    });

    test('lança exceção e mantém lista quando API retorna false', () async {
      when(mockService.deleteAccount('1')).thenAnswer((_) async => false);

      expect(
        () => provider.deleteAccount('1'),
        throwsException,
      );
      expect(provider.accounts.length, 2);
    });
  });

  group('AccountProvider.clearError', () {
    test('limpa o error existente', () async {
      when(mockService.getAll()).thenThrow(Exception('Erro'));
      when(mockRepo.getAll()).thenAnswer((_) async => []);
      await provider.loadAll();

      expect(provider.error, isNotNull);
      provider.clearError();
      expect(provider.error, isNull);
    });

    test('não dispara notifyListeners quando error já é null', () async {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.clearError(); // error já é null

      expect(notifyCount, 0);
    });
  });

  group('AccountProvider.reset', () {
    test('limpa contas, tipos e error após reset', () async {
      when(mockService.getAll()).thenAnswer((_) async => fakeAccounts);
      when(mockTypeService.getAll()).thenAnswer((_) async => fakeTypes);
      stubRepoCache();
      await provider.loadAll();
      await provider.loadAccountTypes();

      provider.reset();

      expect(provider.accounts, isEmpty);
      expect(provider.accountTypes, isEmpty);
      expect(provider.error, isNull);
    });

    test('permite inicializar novamente após reset', () async {
      when(mockService.getAll()).thenAnswer((_) async => fakeAccounts);
      when(mockTypeService.getAll()).thenAnswer((_) async => fakeTypes);
      stubRepoCache();

      await provider.initialize();
      provider.reset();
      await provider.initialize();

      expect(provider.accounts.length, 2);
    });
  });

  group('AccountProvider.totalBalance', () {
    test('calcula soma dos saldos corretamente', () async {
      when(mockService.getAll()).thenAnswer((_) async => fakeAccounts);
      stubRepoCache();

      await provider.loadAll();

      expect(provider.totalBalance, 6000.0); // 1000 + 5000
    });

    test('retorna 0 quando não há contas', () {
      expect(provider.totalBalance, 0.0);
    });
  });
}
