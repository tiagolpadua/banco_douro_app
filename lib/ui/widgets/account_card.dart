import 'package:flutter/material.dart';
import '../../models/account.dart';
import '../../models/account_type.dart';
import '../../services/account_service.dart';
import '../theme/app_colors.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  final List<AccountType> accountTypes;
  final VoidCallback? onUpdate;
  final VoidCallback? onDelete;

  const AccountCard({
    super.key,
    required this.account,
    required this.accountTypes,
    this.onUpdate,
    this.onDelete,
  });

  String _getAccountTypeDescription() {
    if (account.accountType == null) return "Sem tipo";
    final type = accountTypes
        .where((acctType) => acctType.id == account.accountType)
        .firstOrNull;
    return type?.description ?? "Desconhecido";
  }

  Color _getAccountTypeColor() {
    final desc = _getAccountTypeDescription().toUpperCase();
    if (desc.contains('AMBROSIA')) return AppColors.info;
    if (desc.contains('CANJICA')) return AppColors.positive;
    if (desc.contains('PUDIM')) return AppColors.warning;
    if (desc.contains('BRIGADEIRO')) return AppColors.accent;
    return AppColors.textSecondary;
  }

  Future<void> _onDeletePressed(BuildContext context) async {
    // Dialog de confirmacao antes da acao destrutiva
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Excluir Conta'),
        content: Text(
          'Deseja realmente excluir a conta de ${account.name} ${account.lastName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Excluir',
              style: TextStyle(
                color: AppColors.negative,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final success = await AccountService().deleteAccount(account.id);
      if (context.mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta excluida com sucesso!')),
        );
        onDelete?.call();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao excluir conta.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getAccountTypeColor();
    final initials = '${account.name[0]}${account.lastName[0]}'.toUpperCase();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Conta de ${account.name} ${account.lastName}'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar com iniciais
              CircleAvatar(
                radius: 24,
                backgroundColor: typeColor.withValues(alpha: 0.15),
                child: Text(
                  initials,
                  style: TextStyle(
                    color: typeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Informacoes da conta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${account.name} ${account.lastName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Text.Rich para saldo com estilos mistos
                    Text.rich(
                      TextSpan(
                        text: 'Saldo: ',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: 'R\$ ${account.balance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Chip com tipo da conta
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getAccountTypeDescription(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: typeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Acoes (editar e excluir) com InkWell
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionIcon(
                    icon: Icons.edit_outlined,
                    color: AppColors.accent,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Funcionalidade de edicao em breve'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  _ActionIcon(
                    icon: Icons.delete_outline,
                    color: AppColors.negative,
                    onTap: () => _onDeletePressed(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icone de acao usando InkWell em vez de IconButton
class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}
