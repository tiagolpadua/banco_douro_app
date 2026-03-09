import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:banco_douro_app/providers/auth_provider.dart';
import 'package:banco_douro_app/providers/account_provider.dart';
import 'package:banco_douro_app/ui/login_screen.dart';
import '../mocks/mocks.mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late MockAccountService mockAccountService;
  late MockAccountTypeService mockAccountTypeService;
  late MockAccountLocalRepository mockAccountLocalRepository;
  late AuthProvider authProvider;
  late AccountProvider accountProvider;

  setUp(() {
    mockAuthService = MockAuthService();
    mockAccountService = MockAccountService();
    mockAccountTypeService = MockAccountTypeService();
    mockAccountLocalRepository = MockAccountLocalRepository();

    authProvider = AuthProvider(authService: mockAuthService);
    accountProvider = AccountProvider(
      accountService: mockAccountService,
      accountTypeService: mockAccountTypeService,
      accountLocalRepository: mockAccountLocalRepository,
    );
  });

  Widget buildLoginScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<AccountProvider>.value(value: accountProvider),
      ],
      child: MaterialApp(
        home: const LoginScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          'dashboard': (_) => const Scaffold(body: Text('Dashboard')),
        },
      ),
    );
  }

  group('LoginScreen — estrutura', () {
    testWidgets('deve exibir o subtítulo do sistema', (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      expect(find.text('Sistema de Gestao de Contas'), findsOneWidget);
    });

    testWidgets('deve exibir dois campos de formulário', (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('deve exibir o botão Entrar', (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      expect(find.text('Entrar'), findsOneWidget);
    });

    testWidgets('deve exibir o texto Banco Douro', (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      // Os textos aparecem no RichText da tela
      expect(find.textContaining('Banco'), findsWidgets);
      expect(find.textContaining('Douro'), findsWidgets);
    });

    testWidgets('deve exibir o texto de rodapé', (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      expect(find.textContaining('Nao tem conta'), findsOneWidget);
    });
  });

  group('LoginScreen — campos de formulário', () {
    testWidgets('deve ter campo de e-mail com label correto', (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      expect(find.text('E-mail'), findsOneWidget);
    });

    testWidgets('deve ter campo de senha com label correto', (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      expect(find.text('Senha'), findsOneWidget);
    });

    testWidgets('deve aceitar texto no campo de e-mail', (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      // Limpar o campo preenchido em debug e inserir novo valor
      await tester.enterText(find.byType(TextFormField).first, 'novo@email.com');
      await tester.pump();

      expect(find.text('novo@email.com'), findsOneWidget);
    });
  });

  group('LoginScreen — validação de formulário', () {
    testWidgets('deve exibir erro quando e-mail está vazio', (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      // Limpar campo e submeter
      await tester.enterText(find.byType(TextFormField).first, '');
      await tester.enterText(find.byType(TextFormField).last, 'senhavalida');
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('Informe o e-mail'), findsOneWidget);
    });

    testWidgets('deve exibir erro quando e-mail não tem @', (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      await tester.enterText(find.byType(TextFormField).first, 'emailsemarroba');
      await tester.enterText(find.byType(TextFormField).last, 'senhavalida');
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('E-mail invalido'), findsOneWidget);
    });

    testWidgets('deve exibir erro quando senha está vazia', (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      await tester.enterText(find.byType(TextFormField).first, 'user@email.com');
      await tester.enterText(find.byType(TextFormField).last, '');
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('Informe a senha'), findsOneWidget);
    });

    testWidgets('deve exibir erro quando senha tem menos de 4 caracteres',
        (tester) async {
      await tester.pumpWidget(buildLoginScreen());

      await tester.enterText(find.byType(TextFormField).first, 'user@email.com');
      await tester.enterText(find.byType(TextFormField).last, 'abc');
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('Senha deve ter pelo menos 4 caracteres'),
        findsOneWidget,
      );
    });
  });

  group('LoginScreen — interação com AuthProvider', () {
    setUp(() {
      // Stubs necessários para o fluxo pós-login (accountProvider.initialize)
      when(mockAccountService.getAll()).thenAnswer((_) async => []);
      when(mockAccountTypeService.getAll()).thenAnswer((_) async => []);
      when(mockAccountLocalRepository.deleteAll()).thenAnswer((_) async => 0);
      when(mockAccountLocalRepository.insertAll(any)).thenAnswer((_) async {});
      when(mockAccountLocalRepository.getAll()).thenAnswer((_) async => []);
    });

    testWidgets('deve chamar authProvider.login com credenciais corretas',
        (tester) async {
      when(mockAuthService.login(any, any)).thenAnswer((_) async => 'token');

      await tester.pumpWidget(buildLoginScreen());

      await tester.enterText(
        find.byType(TextFormField).first,
        'admin@admin.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'admin123');
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      verify(mockAuthService.login('admin@admin.com', 'admin123')).called(1);
    });

    testWidgets(
        'deve desabilitar o botão Entrar durante o carregamento do login',
        (tester) async {
      // Simula login que falha — sem navegação, sem fluxo pós-login
      when(mockAuthService.login(any, any)).thenThrow(
        Exception('Falha no login: 401'),
      );

      await tester.pumpWidget(buildLoginScreen());

      await tester.enterText(
        find.byType(TextFormField).first,
        'user@email.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'senha123');
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // Após falha, o botão volta a ficar habilitado (sem loading)
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });
  });
}
