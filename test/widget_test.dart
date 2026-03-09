import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:banco_douro_app/main.dart';
import 'package:banco_douro_app/providers/auth_provider.dart';
import 'package:banco_douro_app/providers/account_provider.dart';
import 'mocks/mocks.mocks.dart';

void main() {
  testWidgets('App loads login screen', (WidgetTester tester) async {
    final mockAuthService = MockAuthService();
    final mockAccountService = MockAccountService();
    final mockAccountTypeService = MockAccountTypeService();
    final mockAccountLocalRepository = MockAccountLocalRepository();

    when(mockAuthService.isLoggedIn()).thenAnswer((_) async => false);

    final authProvider = AuthProvider(authService: mockAuthService);
    await authProvider.init();

    final accountProvider = AccountProvider(
      accountService: mockAccountService,
      accountTypeService: mockAccountTypeService,
      accountLocalRepository: mockAccountLocalRepository,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<AccountProvider>.value(value: accountProvider),
        ],
        child: const BancoDouroApp(),
      ),
    );

    expect(find.text('Sistema de Gestao de Contas'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
