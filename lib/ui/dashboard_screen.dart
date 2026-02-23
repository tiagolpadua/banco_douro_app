import 'package:banco_douro_app/services/auth_service.dart';
import 'package:banco_douro_app/services/transaction_service.dart';
import 'package:banco_douro_app/viewmodels/account_viewmodel.dart';
import 'package:flutter/material.dart';
import '/models/account.dart';
import '/models/transaction.dart';
import '/ui/widgets/account_widget.dart';
import '/ui/widgets/add_account_modal.dart';
import 'theme/app_colors.dart';

/// Dashboard principal do app.
/// Demonstra o uso de CustomScrollView com Slivers para compor secoes
/// heterogeneas (AppBar colapsavel, listas horizontais, grids e listas
/// verticais) em um unico scroll contínuo e sem conflitos de rolagem.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AccountViewModel _accountViewModel = AccountViewModel();
  final AuthService _authService = AuthService();
  final TransactionService _transactionService = TransactionService();
  List<Account> _accounts = [];
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _accountViewModel.loadAccounts();
    await _accountViewModel.loadAccountTypes();
    try {
      _transactions = await _transactionService.getAll();
    } catch (_) {}
    setState(() {
      _accounts = _accountViewModel.accounts;
    });
  }

  Future<void> _onLogoutPressed() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, 'login');
    }
  }

  double get _totalBalance =>
      _accounts.fold(0.0, (sum, acc) => sum + acc.balance);

  double get _totalTransactions =>
      _transactions.fold(0.0, (sum, t) => sum + t.amount);

  /// Calcula o numero de colunas do grid com base na largura da tela.
  /// Tecnica de breakpoints manuais com MediaQuery:
  /// - >= 900px (tablet landscape): 4 colunas
  /// - >= 600px (tablet portrait): 3 colunas
  /// - < 600px (celular): 2 colunas
  int _gridColumns(double width) {
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    /// MediaQuery.of(context).size.width - obtem a largura atual da tela.
    /// Usado para calcular breakpoints e adaptar o layout responsivamente.
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AddAccountModal(),
          );
          _loadData();
        },
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      /// SafeArea - garante que o conteudo respeita as areas seguras do
      /// dispositivo (notch, camera, barra de navegacao). Em landscape,
      /// as safe areas laterais sao especialmente importantes.
      /// top: false - o SliverAppBar ja trata a safe area superior.
      ///
      /// CustomScrollView - substitui o body padrao por um scroll unificado
      /// que aceita apenas Slivers como filhos. Isso permite combinar
      /// diferentes tipos de conteudo (AppBar, listas, grids) em um unico
      /// eixo de rolagem, evitando conflitos de scroll aninhado.
      body: SafeArea(
        top: false,
        child: CustomScrollView(
        slivers: [
          /// SliverAppBar - AppBar que participa do scroll dos slivers.
          /// - expandedHeight: altura maxima quando totalmente expandida.
          /// - pinned: true - a AppBar permanece visivel (fixa no topo)
          ///   mesmo quando o utilizador rola para baixo, colapsando ate
          ///   a altura minima. Isso mantem o contexto da tela sempre visivel.
          /// - flexibleSpace com FlexibleSpaceBar: conteudo que escala e
          ///   desaparece suavemente durante o colapso (parallax).
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primary,
            actions: [
              IconButton(
                onPressed: _onLogoutPressed,
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Sair',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Banco Douro',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                ),
                child: const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(left: 20, top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sistema de gestao de contas',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// SliverToBoxAdapter - adapta um widget comum (nao-sliver) para
          /// ser usado dentro de um CustomScrollView. Necessario porque
          /// CustomScrollView so aceita slivers como filhos directos.
          ///
          /// Center + ConstrainedBox(maxWidth: 720) - padrao de
          /// responsividade: o conteudo e centrado e limitado a 720px.
          /// Em celulares ocupa toda a largura; em tablets, fica centralizado
          /// e nao se estica excessivamente, melhorando a legibilidade.
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'Saldo total',
                          value: 'R\$ ${_totalBalance.toStringAsFixed(2)}',
                          icon: Icons.account_balance_wallet,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Transacoes',
                          value: 'R\$ ${_totalTransactions.toStringAsFixed(2)}',
                          icon: Icons.swap_horiz,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Contas',
                          value: '${_accounts.length}',
                          icon: Icons.people,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// Lista horizontal de acoes rapidas dentro de SliverToBoxAdapter.
          /// SizedBox(height: 104) define uma constraint de altura fixa,
          /// necessaria para que o ListView horizontal tenha limites claros
          /// e nao tente ocupar altura infinita dentro do scroll vertical.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Acoes rapidas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 104,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _QuickActionCard(
                          icon: Icons.person_add,
                          label: 'Nova conta',
                          onTap: () => Navigator.pushNamed(context, 'accounts'),
                        ),
                        _QuickActionCard(
                          icon: Icons.swap_horiz,
                          label: 'Transferir',
                          onTap: () =>
                              Navigator.pushNamed(context, 'transactions'),
                        ),
                        _QuickActionCard(
                          icon: Icons.list_alt,
                          label: 'Contas',
                          onTap: () => Navigator.pushNamed(context, 'accounts'),
                        ),
                        _QuickActionCard(
                          icon: Icons.person,
                          label: 'Perfil',
                          onTap: () => Navigator.pushNamed(context, 'profile'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'Atalhos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          /// SliverGrid - grid que participa nativamente do scroll dos slivers.
          /// Ao contrario de GridView dentro de SliverToBoxAdapter, o SliverGrid
          /// nao precisa de altura fixa: ele gera os filhos sob demanda e
          /// integra-se directamente no fluxo de rolagem do CustomScrollView.
          ///
          /// SliverGridDelegateWithFixedCrossAxisCount - define o numero de
          /// colunas fixas. Aqui usamos _gridColumns(screenWidth) para
          /// adaptar o numero de colunas ao breakpoint da largura da tela.
          /// childAspectRatio: 1.6 - controla a proporcao largura/altura
          /// de cada celula do grid.
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _gridColumns(screenWidth),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
              ),
              delegate: SliverChildListDelegate([
                _ShortcutTile(
                  icon: Icons.account_balance,
                  label: 'Contas',
                  onTap: () => Navigator.pushNamed(context, 'accounts'),
                ),
                _ShortcutTile(
                  icon: Icons.receipt_long,
                  label: 'Transacoes',
                  onTap: () => Navigator.pushNamed(context, 'transactions'),
                ),
                _ShortcutTile(
                  icon: Icons.settings,
                  label: 'Perfil',
                  onTap: () => Navigator.pushNamed(context, 'profile'),
                ),
                _ShortcutTile(
                  icon: Icons.logout,
                  label: 'Sair',
                  onTap: _onLogoutPressed,
                ),
              ]),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'Contas recentes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          /// SliverList - lista vertical que participa nativamente do scroll.
          /// Ao contrario de colocar um ListView.builder dentro de
          /// SliverToBoxAdapter (que exigiria altura fixa e causaria scroll
          /// aninhado), SliverList integra cada item directamente no fluxo
          /// de rolagem do CustomScrollView.
          ///
          /// SliverChildBuilderDelegate - constroi os itens sob demanda
          /// (lazy), semelhante ao ListView.builder. childCount define
          /// o numero total de itens.
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return AccountWidget(
                    account: _accounts[index],
                    accountTypes: _accountViewModel.accountTypes,
                    onUpdate: _loadData,
                    onDelete: _loadData,
                  );
                },
                childCount: _accounts.length,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

/// FittedBox - redimensiona o conteudo filho para caber dentro dos limites
/// do pai. Com BoxFit.scaleDown, o texto so e reduzido se ultrapassar a
/// largura disponivel, evitando overflow em telas estreitas.
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 96,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShortcutTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
