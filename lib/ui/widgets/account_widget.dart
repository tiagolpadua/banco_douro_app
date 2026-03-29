import 'dart:math';

import 'package:animations/animations.dart';
import 'package:banco_douro_app/ui/screens/account_detail_screen.dart';
import 'package:flutter/material.dart';
import '../../models/account.dart';
import '../../models/account_type.dart';
import '../theme/app_colors.dart';

class AccountWidget extends StatelessWidget {
  final Account account;
  final List<AccountType> accountTypes;
  final VoidCallback? onDelete;

  const AccountWidget({
    super.key,
    required this.account,
    required this.accountTypes,
    this.onDelete,
  });

  String _getAccountTypeDescription() {
    if (account.accountType == null) return "Sem tipo definido";
    final type = accountTypes
        .where((acctType) => acctType.id == account.accountType)
        .firstOrNull;
    return type?.description ?? "Tipo desconhecido";
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(account.id),
      direction: DismissDirection.endToStart,
      // Fundo vermelho revelado durante o arrasto
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.negative,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'Excluir',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      // Confirmação antes de dispensar
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Excluir conta'),
            content: Text(
              'Deseja excluir a conta de ${account.name} ${account.lastName}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.negative,
                ),
                child: const Text('Excluir'),
              ),
            ],
          ),
        );
      },
      // Chamado após confirmação — delega a exclusão real ao DashboardScreen
      onDismissed: (_) => onDelete?.call(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: OpenContainer(
          transitionDuration: const Duration(milliseconds: 400),
          transitionType: ContainerTransitionType.fadeThrough,
          closedElevation: 0,
          openElevation: 0,
          closedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          closedColor: AppColors.cardBackground,
          openColor: AppColors.background,
          closedBuilder: (context, openContainer) {
            return _ClosedCard(
              account: account,
              onOpenDetail: openContainer,
              getTypeDescription: _getAccountTypeDescription,
              onDeletePressed: onDelete,
            );
          },
          openBuilder: (context, _) {
            return AccountDetailScreen(
              account: account,
              accountTypes: accountTypes,
            );
          },
        ),
      ),
    );
  }
}

class _ClosedCard extends StatelessWidget {
  final Account account;
  final VoidCallback onOpenDetail;
  final String Function() getTypeDescription;
  final VoidCallback? onDeletePressed;

  const _ClosedCard({
    required this.account,
    required this.onOpenDetail,
    required this.getTypeDescription,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpenDetail,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar com Hero para "voar" até a AccountDetailScreen
            Hero(
              tag: 'account-avatar-${account.id}',
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "${account.name[0]}${account.lastName.isNotEmpty ? account.lastName[0] : ''}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Informações da conta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${account.name} ${account.lastName}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "ID: ${account.id.substring(0, min(account.id.length, 5))}  •  ${getTypeDescription()}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "R\$ ${account.balance.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Dica visual: ícone de swipe
            const Icon(
              Icons.swipe_left_outlined,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
