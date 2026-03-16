import 'package:banco_douro_app/providers/account_provider.dart';
import 'package:banco_douro_app/providers/auth_provider.dart';
import 'package:banco_douro_app/ui/theme/app_colors.dart';
import 'package:banco_douro_app/ui/widgets/account_widget.dart';
import 'package:banco_douro_app/ui/widgets/add_account_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  int _gridColumns(double width) {
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  Future<void> _showAddAccountModal(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddAccountModal(),
    );
  }

  Future<void> _logout(BuildContext context) async {
    context.read<AccountProvider>().reset();
    await context.read<AuthProvider>().logout();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, 'login');
    }
  }

  void _showUnavailableFeature(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade ainda nao implementada.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: const Key('dashboardScreen'),
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Consumer<AccountProvider>(
          builder: (context, provider, child) {
            final hasOfflineData =
                provider.error != null && provider.accounts.isNotEmpty;

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 180,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  actions: [
                    IconButton(
                      onPressed: provider.isLoading
                          ? null
                          : () => provider.loadAll(),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      tooltip: 'Atualizar',
                    ),
                    IconButton(
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout, color: Colors.white),
                      tooltip: 'Sair',
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'Banco Douro',
                      style: const TextStyle(
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
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, top: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sistema de gestao de contas',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${provider.accounts.length} contas carregadas',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
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
                if (hasOfflineData)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Text(
                          provider.error!,
                          style: TextStyle(
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'Saldo total',
                            value:
                                'R\$ ${provider.totalBalance.toStringAsFixed(2)}',
                            icon: Icons.account_balance_wallet,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Tipos',
                            value: '${provider.accountTypes.length}',
                            icon: Icons.category_outlined,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Contas',
                            value: '${provider.accounts.length}',
                            icon: Icons.people,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                                onTap: () => _showAddAccountModal(context),
                              ),
                              _QuickActionCard(
                                icon: Icons.refresh,
                                label: 'Atualizar',
                                onTap: provider.isLoading
                                    ? null
                                    : () => provider.loadAll(),
                              ),
                              _QuickActionCard(
                                icon: Icons.wifi_off,
                                label: 'Status API',
                                onTap: () =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          provider.error == null
                                              ? 'Conexao com API ativa.'
                                              : provider.error!,
                                        ),
                                      ),
                                    ),
                              ),
                              _QuickActionCard(
                                icon: Icons.person,
                                label: 'Perfil',
                                onTap: () => _showUnavailableFeature(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: const SizedBox(height: 16)),
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
                        onTap: () => _showAddAccountModal(context),
                      ),
                      _ShortcutTile(
                        icon: Icons.download,
                        label: 'Sincronizar',
                        onTap: provider.isLoading
                            ? null
                            : () => provider.loadAll(),
                      ),
                      _ShortcutTile(
                        icon: Icons.category,
                        label: 'Tipos',
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${provider.accountTypes.length} tipos disponiveis.',
                            ),
                          ),
                        ),
                      ),
                      _ShortcutTile(
                        icon: Icons.logout,
                        label: 'Sair',
                        onTap: () => _logout(context),
                      ),
                    ]),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Contas recentes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (provider.isLoading)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                  ),
                ),
                if (!provider.isLoading && provider.accounts.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'Nenhuma conta encontrada.\nToque em + para adicionar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      key: const Key('accountList'),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final account = provider.accounts[index];
                        return AccountWidget(
                          account: account,
                          accountTypes: provider.accountTypes,
                        );
                      }, childCount: provider.accounts.length),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('addAccountButton'),
        onPressed: () => _showAddAccountModal(context),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
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
  final VoidCallback? onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 120,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.primary, size: 28),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ShortcutTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
