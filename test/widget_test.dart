import 'package:flutter_test/flutter_test.dart';

import 'package:banco_douro_app/main.dart';

void main() {
  testWidgets('App loads login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const BancoDouroApp(isLoggedIn: false));

    expect(find.text('Sistema de Gestao de Contas'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
