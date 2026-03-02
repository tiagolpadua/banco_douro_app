import 'package:banco_douro_app/providers/account_provider.dart';
import 'package:banco_douro_app/providers/auth_provider.dart';
import 'package:banco_douro_app/ui/dashboard_screen.dart';
import 'package:banco_douro_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/home_screen.dart';
import 'ui/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  await authProvider.init();

  final accountProvider = AccountProvider();
  if (authProvider.isLoggedIn) {
    // Dispara o carregamento sem bloquear o runApp.
    // DashboardScreen reage ao estado de loading via Consumer.
    accountProvider.initialize();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<AccountProvider>.value(value: accountProvider),
      ],
      child: const BancoDouroApp(),
    ),
  );
}

class BancoDouroApp extends StatelessWidget {
  const BancoDouroApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;

    return MaterialApp(
      title: 'Banco Douro',
      theme: AppTheme.lightTheme,
      home: isLoggedIn ? const DashboardScreen() : const LoginScreen(),
      routes: {
        "dashboard": (context) => const DashboardScreen(),
        "login": (context) => const LoginScreen(),
        "home": (context) => const HomeScreen(),
      },
    );
  }
}
