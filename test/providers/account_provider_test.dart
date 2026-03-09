import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:banco_douro_app/models/account.dart';
import 'package:banco_douro_app/models/account_type.dart';
import 'package:banco_douro_app/providers/account_provider.dart';
import '../mocks/mocks.mocks.dart';

void main() {
  late MockAccountService mockAccountService;
  late MockAccountTypeService mockAccountTypeService;
  late MockAccountLocalRepository mockAccountLocalRepository;
  late AccountProvider provider;

  final fakeAccounts = [
    Account(
      id: '1',
      name: 'João',
      lastName: 'Silva',
      balance: 1000.0,
      accountType: 'PUDIM',
    ),
    Account(
      id: '2',
      name: 'Maria',
      lastName: 'Costa',
      balance: 5000.0,
      accountType: 'BRIGADEIRO',
    ),
  ];

  final fakeAccountTypes = [
    AccountType(id: 'PUDIM', description: 'Conta Pudim'),
    AccountType(id: 'BRIGADEIRO', description: 'Conta Brigadeiro'),
  ];

  setUp(() {
    mockAccountService = MockAccountService();
    mockAccountTypeService = MockAccountTypeService();
    mockAccountLocalRepository = MockAccountLocalRepository();
    provider = AccountProvider(
      accountService: mockAccountService,
      accountTypeService: mockAccountTypeService,
      accountLocalRepository: mockAccountLocalRepository,
    );
  });

  // Helper para configurar o mock do repositório local (necessário em loadAll)
  void stubLocalRepo() {
    when(mockAccountLocalRepository.deleteAll()).thenAnswer((_) async => 0);
    when(
      mockAccountLocalRepository.insertAll(any),
    ).thenAnswer((_) async => {});
    when(mockAccountLocalRepository.getAll()).thenAnswer((_) async => []);
  }

  group('AccountProvider — estado inicial', () {
    test('deve iniciar com lista de contas vazia', () {
      expect(provider.accounts, isEmpty);
    });

    test('deve iniciar com isLoading = false', () {
      expect(provider.isLoading, isFalse);
    });

    test('deve iniciar sem erro', () {
      expect(provider.error, isNull);
    });

    test('deve iniciar com totalBalance = 0', () {
      expect(provider.totalBalance, 0.0);
    });
  });

  group('AccountProvider.loadAll — sucesso', () {
    setUp(() {
      stubLocalRepo();
      when(
        mockAccountService.getAll(),
      ).thenAnswer((_) async => fakeAccounts);
    });

    test('deve carregar contas da API', () async {
      await provider.loadAll();

      expect(provider.accounts.length, 2);
    });

    test('deve definir isLoading = false após completar', () async {
      await provider.loadAll();

      expect(provider.isLoading, isFalse);
    });

    test('não deve ter erro após carregamento bem-sucedido', () async {
      await provider.loadAll();

      expect(provider.error, isNull);
    });

    test('deve calcular totalBalance corretamente', () async {
      await provider.loadAll();

      expect(provider.totalBalance, 6000.0);
    });

    test('deve chamar deleteAll e insertAll no repositório local', () async {
      await provider.loadAll();

      verify(mockAccountLocalRepository.deleteAll()).called(1);
      verify(mockAccountLocalRepository.insertAll(any)).called(1);
    });
  });

  group('AccountProvider.loadAll — falha na API', () {
    setUp(() {
      when(
        mockAccountService.getAll(),
      ).thenThrow(Exception('Sem conexão'));
      when(
        mockAccountLocalRepository.getAll(),
      ).thenAnswer((_) async => fakeAccounts);
    });

    test('deve usar repositório local quando API falha', () async {
      await provider.loadAll();

      expect(provider.accounts.length, 2);
    });

    test('deve definir mensagem de erro quando API falha', () async {
      await provider.loadAll();

      expect(provider.error, isNotNull);
      expect(provider.error!.isNotEmpty, isTrue);
    });

    test('deve definir isLoading = false mesmo em caso de erro', () async {
      await provider.loadAll();

      expect(provider.isLoading, isFalse);
    });
  });

  group('AccountProvider.loadAccountTypes', () {
    test('deve carregar tipos de conta com sucesso', () async {
      when(
        mockAccountTypeService.getAll(),
      ).thenAnswer((_) async => fakeAccountTypes);

      await provider.loadAccountTypes();

      expect(provider.accountTypes.length, 2);
      expect(provider.isLoadingAccountTypes, isFalse);
    });

    test('deve manter lista vazia quando API de tipos falha', () async {
      when(mockAccountTypeService.getAll()).thenThrow(Exception('Erro'));

      await provider.loadAccountTypes();

      expect(provider.accountTypes, isEmpty);
      expect(provider.isLoadingAccountTypes, isFalse);
    });
  });

  group('AccountProvider.addAccount', () {
    final novaAccount = Account(
      id: '3',
      name: 'Carlos',
      lastName: 'Lima',
      balance: 2000.0,
      accountType: 'CANJICA',
    );

    setUp(() {
      stubLocalRepo();
      when(
        mockAccountService.getAll(),
      ).thenAnswer((_) async => fakeAccounts);
      when(
        mockAccountLocalRepository.insert(any),
      ).thenAnswer((_) async => 1);
    });

    test('deve adicionar conta à lista quando API retorna true', () async {
      when(
        mockAccountService.addAccount(novaAccount),
      ).thenAnswer((_) async => true);

      await provider.loadAll();
      await provider.addAccount(novaAccount);

      expect(provider.accounts.length, 3);
      expect(provider.accounts.any((a) => a.id == '3'), isTrue);
    });

    test('deve inserir conta no repositório local', () async {
      when(
        mockAccountService.addAccount(novaAccount),
      ).thenAnswer((_) async => true);

      await provider.loadAll();
      await provider.addAccount(novaAccount);

      verify(mockAccountLocalRepository.insert(novaAccount)).called(1);
    });

    test('deve lançar Exception quando API retorna false', () async {
      when(
        mockAccountService.addAccount(novaAccount),
      ).thenAnswer((_) async => false);

      await provider.loadAll();

      expect(
        () async => await provider.addAccount(novaAccount),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('AccountProvider.deleteAccount', () {
    setUp(() async {
      stubLocalRepo();
      when(
        mockAccountService.getAll(),
      ).thenAnswer((_) async => fakeAccounts);
      when(
        mockAccountLocalRepository.delete(any),
      ).thenAnswer((_) async => 1);
      await provider.loadAll();
    });

    test('deve remover conta da lista quando API retorna true', () async {
      when(
        mockAccountService.deleteAccount('1'),
      ).thenAnswer((_) async => true);

      await provider.deleteAccount('1');

      expect(provider.accounts.any((a) => a.id == '1'), isFalse);
      expect(provider.accounts.length, 1);
    });

    test('deve deletar conta do repositório local', () async {
      when(
        mockAccountService.deleteAccount('1'),
      ).thenAnswer((_) async => true);

      await provider.deleteAccount('1');

      verify(mockAccountLocalRepository.delete('1')).called(1);
    });

    test('deve lançar Exception quando API retorna false', () async {
      when(
        mockAccountService.deleteAccount('1'),
      ).thenAnswer((_) async => false);

      expect(
        () async => await provider.deleteAccount('1'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('AccountProvider.clearError', () {
    test('deve limpar o erro', () async {
      when(mockAccountService.getAll()).thenThrow(Exception('erro'));
      when(
        mockAccountLocalRepository.getAll(),
      ).thenAnswer((_) async => []);

      await provider.loadAll();
      expect(provider.error, isNotNull);

      provider.clearError();
      expect(provider.error, isNull);
    });

    test('não deve notificar listeners se não havia erro', () {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.clearError();

      expect(notifyCount, 0);
    });
  });

  group('AccountProvider.reset', () {
    test('deve limpar contas, tipos e erros', () async {
      stubLocalRepo();
      when(
        mockAccountService.getAll(),
      ).thenAnswer((_) async => fakeAccounts);
      when(
        mockAccountTypeService.getAll(),
      ).thenAnswer((_) async => fakeAccountTypes);

      await provider.initialize();
      provider.reset();

      expect(provider.accounts, isEmpty);
      expect(provider.accountTypes, isEmpty);
      expect(provider.error, isNull);
    });
  });
}
