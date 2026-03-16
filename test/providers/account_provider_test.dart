import 'package:banco_douro_app/models/account.dart';
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
    Account(
      id: '1',
      name: 'João',
      lastName: 'Silva',
      balance: 1000,
      accountType: 'PUDIM',
    ),
    Account(
      id: '2',
      name: 'Maria',
      lastName: 'Costa',
      balance: 5000,
      accountType: 'BRIGADEIRO',
    ),
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
  });
}
