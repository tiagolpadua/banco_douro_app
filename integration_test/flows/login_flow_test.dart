import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:banco_douro_app/main.dart' as app;
import 'package:banco_douro_app/providers/auth_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Garantir que o usuário não está logado antes de cada teste
    final auth = AuthProvider();
    await auth.init();
    if (auth.isLoggedIn) {
      await auth.logout();
    }
  });

  group('Fluxo de Login', () {
    testWidgets('deve navegar para Dashboard com credenciais válidas', (
      tester,
    ) async {
      app.main();

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verificar tela de login
      expect(find.byKey(const Key('loginScreen')), findsOneWidget);

      // Preencher formulário
      await tester.enterText(
        find.byKey(const Key('emailField')),
        'admin@admin.com',
      );

      await tester.enterText(find.byKey(const Key('passwordField')), 'admin');

      // Tocar no botão
      await tester.tap(find.byKey(const Key('loginButton')));

      // Aguardar navegação e carregamento (rede pode demorar)
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Verificar que chegou no dashboard
      expect(find.byKey(const Key('dashboardScreen')), findsOneWidget);
    });

    testWidgets('deve exibir erro com credenciais inválidas', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verificar tela de login
      expect(find.byKey(const Key('loginScreen')), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('emailField')),
        'admin@admin.com',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'senha_errada',
      );

      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Deve continuar na tela de login
      expect(find.byKey(const Key('loginScreen')), findsOneWidget);
    });

    testWidgets('deve exibir erro de validação com campos vazios', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verificar tela de login
      expect(find.byKey(const Key('loginScreen')), findsOneWidget);

      // Limpar campos pré-preenchidos (kDebugMode preenche automaticamente)
      await tester.enterText(find.byKey(const Key('emailField')), '');
      await tester.enterText(find.byKey(const Key('passwordField')), '');

      // Só tocar no botão
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pump();

      // Validação do formulário deve aparecer
      expect(find.text('Informe o e-mail'), findsOneWidget);
    });
  });
}
