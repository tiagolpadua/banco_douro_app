import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class LoginPage {
  final WidgetTester tester;

  const LoginPage(this.tester);

  Future<void> isVisible() async {
    expect(find.byKey(const Key('loginScreen')), findsOneWidget);
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await tester.enterText(find.byKey(const Key('emailField')), email);
    await tester.enterText(find.byKey(const Key('passwordField')), password);
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle(const Duration(seconds: 10));
  }

  Future<void> hasValidationError(String message) async {
    expect(find.text(message), findsOneWidget);
  }

  Future<void> hasErrorSnackbar(String message) async {
    expect(find.text(message), findsOneWidget);
  }
}
