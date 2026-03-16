import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class AddAccountPage {
  final WidgetTester tester;

  const AddAccountPage(this.tester);

  Future<void> isVisible() async {
    expect(find.byKey(const Key('saveAccountButton')), findsOneWidget);
  }

  Future<void> fillForm({
    required String name,
    required String lastName,
    // accountTypeId: o valor do id do tipo (ex: 'PUDIM'), ou null para usar o primeiro
    String? accountTypeId,
  }) async {
    await tester.enterText(find.byKey(const Key('nameField')), name);
    await tester.enterText(find.byKey(const Key('lastNameField')), lastName);

    if (accountTypeId != null) {
      // Abrir dropdown
      await tester.tap(find.byKey(const Key('accountTypeDropdown')));
      await tester.pumpAndSettle();

      // Encontrar o DropdownMenuItem com o value correto
      final targetItem = find.byWidgetPredicate((widget) =>
          widget is DropdownMenuItem<String> && widget.value == accountTypeId);

      if (targetItem.evaluate().isNotEmpty) {
        // Garantir que o item está visível antes de tocar
        await tester.ensureVisible(targetItem.last);
        await tester.pumpAndSettle();
        await tester.tap(targetItem.last, warnIfMissed: false);
      } else {
        // Fallback: fechar o dropdown sem selecionar
        await tester.tapAt(const Offset(10, 10));
      }
      await tester.pumpAndSettle();
    }
  }

  Future<void> save() async {
    await tester.tap(find.byKey(const Key('saveAccountButton')));
    await tester.pumpAndSettle(const Duration(seconds: 10));
  }
}
