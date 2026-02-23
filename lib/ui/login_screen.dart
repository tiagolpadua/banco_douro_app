import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import 'theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _emailController.text = 'admin@admin.com';
      _passwordController.text = 'admin';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe o e-mail';
    }
    if (!value.contains('@')) {
      return 'E-mail invalido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe a senha';
    }
    if (value.length < 4) {
      return 'Senha deve ter pelo menos 4 caracteres';
    }
    return null;
  }

  Future<void> _onLoginPressed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      await _authService.login(email, password);
      if (mounted) {
        Navigator.pushReplacementNamed(context, 'dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao conectar: ${e.toString()}'),
            backgroundColor: AppColors.negative,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Fundo com gradiente no topo
            Container(
              height: 320,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
              ),
            ),

            // Imagens decorativas (mantendo assets existentes)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                "assets/images/banner.png",
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.3),
              ),
            ),
            Positioned(
              top: 40,
              left: 16,
              child: Image.asset(
                "assets/images/stars.png",
                opacity: const AlwaysStoppedAnimation(0.5),
              ),
            ),

            // Conteudo principal
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 48),

                      // Logo
                      Image.asset("assets/images/logo.png", width: 100),

                      const SizedBox(height: 24),

                      // Titulo com Text.Rich - estilos mistos
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Banco ',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: 'Douro',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        'Sistema de Gestao de Contas',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white60,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Card de formulario com BoxDecoration
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Acesse sua conta',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Insira suas credenciais para continuar',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Campo de email
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                              decoration: const InputDecoration(
                                labelText: 'E-mail',
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Campo de senha
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              validator: _validatePassword,
                              decoration: const InputDecoration(
                                labelText: 'Senha',
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Botao de login
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _onLoginPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Entrar'),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Texto de rodape com Text.Rich
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Nao tem conta? ',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextSpan(
                              text: 'Fale com seu gerente',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool?> showConfirmationDialog(
  BuildContext context, {
  String title = 'Atencao!',
  String content = 'Deseja realizar esta operacao?',
  String confirmText = 'Confirmar',
  String cancelText = 'Cancelar',
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            confirmText,
            style: const TextStyle(
              color: AppColors.negative,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
