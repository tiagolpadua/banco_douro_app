import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../exceptions/api_exceptions.dart';
import 'styles/colors.dart';
import 'widgets/confirmation_dialog.dart';
import 'widgets/exception_dialog.dart';

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
      return 'E-mail inválido';
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
        Navigator.pushReplacementNamed(context, 'home');
      }
    } on UserNotFoundException {
      if (mounted) {
        _offerRegistration(email, password);
      }
    } on HttpException catch (e) {
      if (mounted) {
        showExceptionDialog(context, content: e.message);
      }
    } catch (e) {
      if (mounted) {
        showExceptionDialog(
          context,
          content:
              'Erro ao conectar com o servidor. Verifique sua conexão: ${e.toString()}',
        );
      }
      rethrow;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _offerRegistration(String email, String password) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Usuário não encontrado',
      content: 'Deseja criar uma nova conta com o e-mail $email?',
      confirmText: 'Criar conta',
      cancelText: 'Cancelar',
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await _authService.register(email, password);
        if (mounted) {
          Navigator.pushReplacementNamed(context, 'home');
        }
      } on HttpException catch (e) {
        if (mounted) {
          showExceptionDialog(context, content: e.message);
        }
      } catch (e) {
        if (mounted) {
          showExceptionDialog(
            context,
            content: 'Erro ao criar conta. Tente novamente: ${e.toString()}',
          );
        }
        rethrow;
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Image.asset("assets/images/banner.png"),
              Align(
                alignment: Alignment.bottomLeft,
                child: Image.asset("assets/images/stars.png"),
              ),
              Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 200),
                      Image.asset("assets/images/logo.png", width: 120),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 32),
                          const Text(
                            "Sistema de Gestao de Contas",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                            decoration: const InputDecoration(
                              label: Text("E-mail"),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            validator: _validatePassword,
                            decoration: const InputDecoration(
                              label: Text("Senha"),
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _onLoginPressed,
                            style: const ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                AppColor.orange,
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Text(
                                    "Entrar",
                                    style: TextStyle(color: Colors.black),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
