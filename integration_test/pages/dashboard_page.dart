import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class DashboardPage {
  final WidgetTester tester;

  const DashboardPage(this.tester);

  Future<void> isVisible() async {
    expect(find.byKey(const Key('dashboardScreen')), findsOneWidget);
  }

  Future<void> tapAddAccount() async {
    await tester.tap(find.byKey(const Key('addAccountButton')));
    await tester.pumpAndSettle();
  }

  Future<void> hasAccountWithName(String name) async {
    // Pump para garantir que a lista foi atualizada após fechar o modal
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Rola para baixo repetidamente até encontrar o item ou esgotar tentativas
    const scrollStep = Offset(0, -300);
    for (int i = 0; i < 10; i++) {
      if (find.text(name).evaluate().isNotEmpty) break;
      await tester.drag(find.byType(CustomScrollView).first, scrollStep);
      await tester.pumpAndSettle();
    }

    expect(find.text(name), findsOneWidget);
  }

  Future<void> doesNotHaveAccountWithName(String name) async {
    expect(find.text(name), findsNothing);
  }

  Future<void> scrollToAccount(String name) async {
    const scrollStep = Offset(0, -300);
    for (int i = 0; i < 10; i++) {
      if (find.text(name).evaluate().isNotEmpty) break;
      await tester.drag(find.byType(CustomScrollView).first, scrollStep);
      await tester.pumpAndSettle();
    }
  }
}
