import 'package:banco_douro_app/providers/account_provider.dart';
import 'package:banco_douro_app/ui/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:banco_douro_app/providers/auth_provider.dart';

import '../mocks/mocks.mocks.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:provider/provider.dart';
// import 'package:banco_douro_app/providers/auth_provider.dart';
// import 'package:banco_douro_app/ui/screens/login_screen.dart';

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockAccountProvider mockAccountProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockAccountProvider = MockAccountProvider();
    when(mockAuthProvider.isLoggedIn).thenReturn(false);
  });

  Widget buildLoginScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<AccountProvider>.value(
          value: mockAccountProvider,
        ),
      ],
      child: MaterialApp(
        home: const LoginScreen(),
        routes: {
          'dashboard': (_) => const Scaffold(body: Text('Dashboard')),
        },
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('exibe título do app', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      expect(find.text('Sistema de Gestao de Contas'), findsOneWidget);
    });

    testWidgets('exibe botão Entrar', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      expect(find.text('Entrar'), findsOneWidget);
    });

    testWidgets('chama login ao pressionar Entrar', (tester) async {
      when(mockAuthProvider.login(any, any)).thenAnswer((_) async => true);

      await tester.pumpWidget(buildLoginScreen());
      await tester.enterText(
        find.byKey(const Key('emailField')).first,
        'admin@admin.com',
      );
      await tester.enterText(find.byKey(const Key('passwordField')), 'admin');
      await tester.tap(find.text('Entrar'));

      await tester.pump();

      verify(mockAuthProvider.login('admin@admin.com', 'admin')).called(1);
    });
  });
}
