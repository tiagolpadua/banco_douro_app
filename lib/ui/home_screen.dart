import 'package:banco_douro_app/services/auth_service.dart';
import 'package:banco_douro_app/viewmodels/account_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/account.dart';
import 'theme/app_colors.dart';
import 'widgets/header_widget.dart';
import 'widgets/balance_card.dart';
import 'widgets/action_button.dart';
import 'widgets/account_card.dart';
import 'widgets/transaction_tile.dart';
import 'widgets/add_account_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AccountViewModel _accountViewModel = AccountViewModel();
  List<Account> _listAccounts = [];
  final AuthService _authService = AuthService();
  bool _isBalanceVisible = true;
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    refreshGetAll();
  }

  Future<void> refreshGetAll() async {
    await _accountViewModel.loadAccounts();
    await _accountViewModel.loadAccountTypes();
    setState(() {
      _listAccounts = _accountViewModel.accounts;
    });
  }

  double get _totalBalance {
    if (_listAccounts.isEmpty) return 0;
    return _listAccounts.fold(0.0, (sum, account) => sum + account.balance);
  }

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
  }

  Future<void> _onLogoutPressed() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, 'login');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _openAddAccountModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return const AddAccountModal();
      },
    );
    refreshGetAll();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== HEADER COM GRADIENTE =====
                HeaderWidget(
                  userName: 'Maria',
                  agency: '0001',
                  account: '12345-6',
                  onLogout: _onLogoutPressed,
                ),

                // ===== CARTAO DE SALDO =====
                BalanceCard(
                  balance: _totalBalance,
                  isVisible: _isBalanceVisible,
                  onToggleVisibility: _toggleBalanceVisibility,
                ),

                // ===== BOTOES DE ACOES (linha 1) =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ActionButton(
                        icon: Icons.pix,
                        label: 'Pix',
                        onTap: () => _showSnackBar('Pix - Em breve!'),
                      ),
                      ActionButton(
                        icon: Icons.swap_horiz,
                        label: 'Transferir',
                        onTap: () => _showSnackBar('Transferencia - Em breve!'),
                      ),
                      ActionButton(
                        icon: Icons.add_circle_outline,
                        label: 'Depositar',
                        onTap: () => _showSnackBar('Deposito - Em breve!'),
                      ),
                      ActionButton(
                        icon: Icons.payment,
                        label: 'Pagar',
                        onTap: () => _showSnackBar('Pagamento - Em breve!'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ===== BOTOES DE ACOES (linha 2) =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ActionButton(
                        icon: Icons.phone_android,
                        label: 'Recarga',
                        onTap: () => _showSnackBar('Recarga - Em breve!'),
                        iconColor: AppColors.info,
                      ),
                      ActionButton(
                        icon: Icons.security,
                        label: 'Seguros',
                        onTap: () => _showSnackBar('Seguros - Em breve!'),
                        iconColor: AppColors.positive,
                      ),
                      ActionButton(
                        icon: Icons.account_balance,
                        label: 'Emprestimo',
                        onTap: () => _showSnackBar('Emprestimo - Em breve!'),
                        iconColor: AppColors.warning,
                      ),
                      ActionButton(
                        icon: Icons.trending_up,
                        label: 'Investir',
                        onTap: () => _showSnackBar('Investimentos - Em breve!'),
                        iconColor: AppColors.negative,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ===== SECAO: SUAS CONTAS =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Suas contas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      InkWell(
                        onTap: _openAddAccountModal,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.add,
                                size: 16,
                                color: AppColors.accent,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Nova conta',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Lista de contas (nao-scrollavel dentro do SingleChildScrollView)
                if (_listAccounts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'Nenhuma conta cadastrada.\nToque em "Nova conta" para adicionar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                else
                  ..._listAccounts.map(
                    (account) => AccountCard(
                      account: account,
                      accountTypes: _accountViewModel.accountTypes,
                      onUpdate: refreshGetAll,
                      onDelete: refreshGetAll,
                    ),
                  ),

                const SizedBox(height: 24),

                // ===== SECAO: ULTIMAS TRANSACOES (MOCK) =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ultimas transacoes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            _showSnackBar('Extrato completo - Em breve!'),
                        child: const Text(
                          'Ver tudo',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Transacoes mock para demonstrar o widget
                const TransactionTile(
                  title: 'Supermercado Extra',
                  subtitle: 'Hoje, 14:30',
                  amount: -150.00,
                  icon: Icons.shopping_cart,
                ),
                const TransactionTile(
                  title: 'Salario - Empresa XYZ',
                  subtitle: 'Ontem, 08:00',
                  amount: 3500.00,
                  icon: Icons.work,
                ),
                const TransactionTile(
                  title: 'Netflix',
                  subtitle: '05/02, 00:00',
                  amount: -55.90,
                  icon: Icons.tv,
                ),
                const TransactionTile(
                  title: 'Pix Recebido - Joao',
                  subtitle: '04/02, 16:45',
                  amount: 200.00,
                  icon: Icons.pix,
                ),
                const TransactionTile(
                  title: 'Conta de Luz',
                  subtitle: '03/02, 10:15',
                  amount: -189.50,
                  icon: Icons.bolt,
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // ===== BARRA DE NAVEGACAO INFERIOR =====
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedNavIndex,
          onTap: (index) {
            setState(() => _selectedNavIndex = index);
            if (index != 0) {
              _showSnackBar('Secao em breve!');
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(
              icon: Icon(Icons.credit_card),
              label: 'Cartoes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Extrato',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}
