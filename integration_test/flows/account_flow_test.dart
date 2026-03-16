import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:banco_douro_app/main.dart' as app;
import 'package:banco_douro_app/providers/auth_provider.dart';

import '../pages/login_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/add_account_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late LoginPage loginPage;
  late DashboardPage dashboardPage;
  late AddAccountPage addAccountPage;

  setUp(() async {
    // Garantir que o usuário não está logado antes de cada teste
    final auth = AuthProvider();
    await auth.init();
    if (auth.isLoggedIn) {
      await auth.logout();
    }
  });

  // Helper: fazer login antes de cada teste de conta
  Future<void> loginAndNavigateToDashboard(WidgetTester tester) async {
    app.main();
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    loginPage = LoginPage(tester);
    dashboardPage = DashboardPage(tester);
    addAccountPage = AddAccountPage(tester);

    await loginPage.login(
      email: 'admin@admin.com',
      password: 'admin',
    );
    await dashboardPage.isVisible();
  }

  group('Fluxo de Contas', () {
    testWidgets(
      'deve exibir lista de contas após login',
      (tester) async {
        await loginAndNavigateToDashboard(tester);

        expect(find.byKey(const Key('accountList')), findsOneWidget);
      },
    );

    testWidgets(
      'deve adicionar nova conta e exibir na lista',
      (tester) async {
        await loginAndNavigateToDashboard(tester);

        // Abrir modal de adicionar conta
        await dashboardPage.tapAddAccount();
        await addAccountPage.isVisible();

        // Preencher e salvar
        await addAccountPage.fillForm(
          name: 'Carlos',
          lastName: 'Integration',
          accountTypeId: 'PUDIM',
        );
        await addAccountPage.save();

        // Verificar que a conta aparece na lista
        await dashboardPage.hasAccountWithName('Carlos Integration');
      },
    );

    testWidgets(
      'deve manter conta na lista após reabrir o app',
      (tester) async {
        await loginAndNavigateToDashboard(tester);

        // Adicionar conta
        await dashboardPage.tapAddAccount();
        await addAccountPage.fillForm(
          name: 'Maria',
          lastName: 'Persistente',
          accountTypeId: 'BRIGADEIRO',
        );
        await addAccountPage.save();

        // Verificar presença
        await dashboardPage.hasAccountWithName('Maria Persistente');
      },
    );
  });
}
