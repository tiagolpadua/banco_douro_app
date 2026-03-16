import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:banco_douro_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app inicia na tela de login ou dashboard', (tester) async {
    app.main();
    // Pump para processar o runApp e as inicializações assíncronas
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // O app deve iniciar em uma das telas principais
    final onLogin = find.byKey(const Key('loginScreen')).evaluate().isNotEmpty;
    final onDashboard =
        find.byKey(const Key('dashboardScreen')).evaluate().isNotEmpty;

    expect(onLogin || onDashboard, isTrue,
        reason: 'App deve iniciar na tela de login ou dashboard');

    if (onLogin) {
      expect(find.text('Entrar'), findsOneWidget);
    }
  });
}
