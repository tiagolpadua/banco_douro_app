import 'package:animations/animations.dart';
import 'package:banco_douro_app/ui/dashboard_screen.dart';
import 'package:banco_douro_app/ui/login_screen.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// ABORDAGEM ALTERNATIVA: PageTransitionsTheme
//
// Em vez de usar AppRoutes + PageRouteBuilder por rota, é possível definir
// a transição padrão globalmente no ThemeData. Com isso, qualquer
// Navigator.pushNamed / MaterialPageRoute já usará a transição configurada
// — sem precisar de onGenerateRoute nem PageRouteBuilder.
//
// Como configurar (em app_theme.dart, dentro do ThemeData):
//
//   theme: ThemeData(
//     pageTransitionsTheme: PageTransitionsTheme(
//       builders: {
//         TargetPlatform.android: SharedAxisPageTransitionsBuilder(
//           transitionType: SharedAxisTransitionType.scaled,
//         ),
//         TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(
//           transitionType: SharedAxisTransitionType.scaled,
//         ),
//       },
//     ),
//   ),
//
// Builders disponíveis no pacote animations:
//   SharedAxisPageTransitionsBuilder  — SharedAxis (X, Y ou Z)
//   FadeThroughPageTransitionsBuilder — FadeThrough
//
// Builders nativos do Flutter (sem o pacote animations):
//   ZoomPageTransitionsBuilder        — zoom padrão do Material 3
//   CupertinoPageTransitionsBuilder   — slide do iOS
//   FadeUpwardsPageTransitionsBuilder — fade antigo do Material
//
// QUANDO USAR CADA ABORDAGEM:
//
//   PageTransitionsTheme  → Transição uniforme em todo o app sem esforço.
//                           Limitação: não permite transições diferentes
//                           por rota (ex: login usa scaled, outras usam horizontal).
//
//   AppRoutes (atual)     → Controle por rota. Cada tela pode ter sua própria
//                           transição. Necessário quando rotas têm relações
//                           de navegação distintas.
// ---------------------------------------------------------------------------

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
