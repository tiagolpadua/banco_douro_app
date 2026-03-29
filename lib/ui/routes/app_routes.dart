import 'package:animations/animations.dart';
import 'package:banco_douro_app/ui/dashboard_screen.dart';
import 'package:banco_douro_app/ui/login_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case 'login':
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, _, _) => const LoginScreen(),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.scaled,
              child: child,
            );
          },
        );
      case 'dashboard':
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, _, _) => const DashboardScreen(),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.scaled,
              child: child,
            );
          },
        );
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
