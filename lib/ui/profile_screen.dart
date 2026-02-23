import 'package:banco_douro_app/services/auth_service.dart';
import 'package:banco_douro_app/viewmodels/account_viewmodel.dart';
import 'package:flutter/material.dart';
import 'theme/app_colors.dart';

/// Tela de perfil com constraints de leitura.
/// Demonstra o padrao Center + ConstrainedBox(maxWidth) para garantir
/// que o conteudo nao se estique excessivamente em telas grandes.
/// Em celulares, ocupa toda a largura; em tablets, fica centrado com
/// largura maxima de 600px para manter a legibilidade.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final AccountViewModel _accountViewModel = AccountViewModel();
  int _totalAccounts = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _accountViewModel.loadAccounts();
    setState(() {
      _totalAccounts = _accountViewModel.accounts.length;
    });
  }

  Future<void> _onLogoutPressed() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, 'login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        /// Center + ConstrainedBox(maxWidth: 600) - padrao de responsividade
        /// para conteudo de leitura. O Center garante que o ConstrainedBox
        /// fique centrado horizontalmente, e maxWidth: 600 limita a largura
        /// para que em tablets o conteudo nao fique espalhado por toda a
        /// tela, mantendo uma largura confortavel para leitura.
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // Avatar e nome
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Administrador',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'admin@admin.com',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _ProfileCard(
                  title: 'Dados da conta',
                  children: [
                    _ProfileInfoRow(
                      icon: Icons.email_outlined,
                      label: 'E-mail',
                      value: 'admin@admin.com',
                    ),
                    const Divider(height: 1),
                    _ProfileInfoRow(
                      icon: Icons.people_outline,
                      label: 'Total de contas',
                      value: '$_totalAccounts',
                    ),
                    const Divider(height: 1),
                    _ProfileInfoRow(
                      icon: Icons.security,
                      label: 'Perfil',
                      value: 'Administrador',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _ProfileCard(
                  title: 'Preferencias',
                  children: [
                    _ProfileInfoRow(
                      icon: Icons.language,
                      label: 'Idioma',
                      value: 'Portugues',
                    ),
                    const Divider(height: 1),
                    _ProfileInfoRow(
                      icon: Icons.palette_outlined,
                      label: 'Tema',
                      value: 'Claro',
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                /// ConstrainedBox(maxWidth: 400) - limita a largura do botao
                /// para que nao se estique em telas largas. Mesmo dentro de
                /// um ConstrainedBox pai de 600px, o botao fica ainda mais
                /// compacto para manter a proporcao visual adequada.
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _onLogoutPressed,
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          'Sair da conta',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.negative,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
