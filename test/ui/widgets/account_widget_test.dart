import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:banco_douro_app/models/account.dart';
import 'package:banco_douro_app/models/account_type.dart';
import 'package:banco_douro_app/providers/account_provider.dart';
import 'package:banco_douro_app/ui/widgets/account_widget.dart';
import '../../mocks/mocks.mocks.dart';

void main() {
  late MockAccountService mockAccountService;
  late MockAccountTypeService mockAccountTypeService;
  late MockAccountLocalRepository mockAccountLocalRepository;
  late AccountProvider accountProvider;

  final fakeAccount = Account(
    id: 'abc-001',
    name: 'João',
    lastName: 'Silva',
    balance: 2500.0,
    accountType: 'PUDIM',
  );

  final fakeAccountTypes = [
    AccountType(id: 'PUDIM', description: 'Conta Pudim'),
    AccountType(id: 'BRIGADEIRO', description: 'Conta Brigadeiro'),
  ];

  setUp(() {
    mockAccountService = MockAccountService();
    mockAccountTypeService = MockAccountTypeService();
    mockAccountLocalRepository = MockAccountLocalRepository();

    accountProvider = AccountProvider(
      accountService: mockAccountService,
      accountTypeService: mockAccountTypeService,
      accountLocalRepository: mockAccountLocalRepository,
    );
  });

  Widget buildAccountWidget({
    Account? account,
    List<AccountType>? types,
    VoidCallback? onDelete,
  }) {
    return ChangeNotifierProvider<AccountProvider>.value(
      value: accountProvider,
      child: MaterialApp(
        home: Scaffold(
          body: AccountWidget(
            account: account ?? fakeAccount,
            accountTypes: types ?? fakeAccountTypes,
            onDelete: onDelete,
          ),
        ),
      ),
    );
  }

  group('AccountWidget — exibição de dados', () {
    testWidgets('deve exibir o nome completo do titular', (tester) async {
      await tester.pumpWidget(buildAccountWidget());

      expect(find.text('João Silva'), findsOneWidget);
    });

    testWidgets('deve exibir o saldo formatado', (tester) async {
      await tester.pumpWidget(buildAccountWidget());

      expect(find.textContaining('2500.00'), findsOneWidget);
    });

    testWidgets('deve exibir a descrição do tipo de conta', (tester) async {
      await tester.pumpWidget(buildAccountWidget());

      expect(find.textContaining('Conta Pudim'), findsOneWidget);
    });

    testWidgets('deve exibir iniciais do titular no avatar', (tester) async {
      await tester.pumpWidget(buildAccountWidget());

      // João Silva → iniciais JS
      expect(find.text('JS'), findsOneWidget);
    });

    testWidgets('deve exibir "Tipo desconhecido" para tipo não encontrado',
        (tester) async {
      final accountComTipoEstranho = fakeAccount.copyWith(
        accountType: 'INEXISTENTE',
      );
      await tester.pumpWidget(
        buildAccountWidget(account: accountComTipoEstranho),
      );

      expect(find.textContaining('Tipo desconhecido'), findsOneWidget);
    });

    testWidgets('deve exibir "Sem tipo definido" quando accountType é null',
        (tester) async {
      final accountNullType = Account(
        id: 'x',
        name: 'Sem',
        lastName: 'Tipo',
        balance: 100,
        accountType: null,
      );
      await tester.pumpWidget(
        buildAccountWidget(account: accountNullType),
      );

      expect(find.textContaining('Sem tipo definido'), findsOneWidget);
    });
  });

  group('AccountWidget — botões de ação', () {
    testWidgets('deve exibir botão de editar', (tester) async {
      await tester.pumpWidget(buildAccountWidget());

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('deve exibir botão de excluir', (tester) async {
      await tester.pumpWidget(buildAccountWidget());

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('deve chamar deleteAccount ao pressionar excluir',
        (tester) async {
      when(
        mockAccountService.deleteAccount(fakeAccount.id),
      ).thenAnswer((_) async => true);
      when(
        mockAccountLocalRepository.delete(any),
      ).thenAnswer((_) async => 1);

      await tester.pumpWidget(buildAccountWidget());

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      verify(mockAccountService.deleteAccount(fakeAccount.id)).called(1);
    });
  });
}
