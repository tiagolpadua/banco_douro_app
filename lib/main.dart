import 'package:banco_douro_app/services/auth_service.dart';
import 'package:banco_douro_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'ui/home_screen.dart';
import 'ui/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authService = AuthService();
  final isLoggedIn = await authService.isLoggedIn();

  runApp(BancoDouroApp(isLoggedIn: isLoggedIn));
}

class BancoDouroApp extends StatelessWidget {
  final bool isLoggedIn;

  const BancoDouroApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banco Douro',
      theme: AppTheme.lightTheme,
      routes: {
        "login": (context) => const LoginScreen(),
        "home": (context) => const HomeScreen(),
      },
      initialRoute: isLoggedIn ? "home" : "login",
    );
  }
}
