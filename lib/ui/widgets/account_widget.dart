import 'dart:math';

import 'package:flutter/material.dart';
import '../../models/account.dart';
import '../../models/account_type.dart';
import '../../services/account_service.dart';
import '../../exceptions/api_exceptions.dart';
import '../styles/colors.dart';
import 'confirmation_dialog.dart';
import 'exception_dialog.dart';
import 'edit_account_modal.dart';

class AccountWidget extends StatelessWidget {
  final Account account;
  final List<AccountType> accountTypes;
  final VoidCallback? onUpdate;
  final VoidCallback? onDelete;

  const AccountWidget({
    super.key,
    required this.account,
    required this.accountTypes,
    this.onUpdate,
    this.onDelete,
  });

  String _getAccountTypeDescription() {
    if (account.accountType == null) return "Sem tipo definido";
    final type = accountTypes
        .where((acctType) => acctType.id == account.accountType)
        .firstOrNull;
    return type?.description ?? "Tipo desconhecido";
  }

  void _onEditPressed(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditAccountModal(
        account: account,
        onSaved: onUpdate,
      ),
    );
  }

  Future<void> _onDeletePressed(BuildContext context) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Excluir Conta',
      content: 'Deseja realmente excluir a conta de ${account.name} ${account.lastName}?',
      confirmText: 'Excluir',
    );

    if (confirmed != true) return;

    try {
      final success = await AccountService().deleteAccount(account.id);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conta excluída com sucesso!')),
          );
          onDelete?.call();
        } else {
          showExceptionDialog(context, content: 'Falha ao excluir conta.');
        }
      }
    } on TokenExpiredException {
      if (context.mounted) {
        showExceptionDialog(
          context,
          title: 'Sessão expirada',
          content: 'Por favor, faça login novamente.',
        );
        Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
      }
    } on ServerException catch (e) {
      if (context.mounted) {
        showExceptionDialog(context, content: e.message);
      }
    } catch (e) {
      if (context.mounted) {
        showExceptionDialog(
          context,
          content: 'Erro ao excluir conta. Tente novamente.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColor.lightOrange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${account.name} ${account.lastName}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("ID: ${account.id.substring(0, min(account.id.length, 5))}"),
                Text("Saldo: ${account.balance.toStringAsFixed(2)}"),
                Text("Tipo: ${_getAccountTypeDescription()}"),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: AppColor.orange),
                onPressed: () => _onEditPressed(context),
                tooltip: 'Editar',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _onDeletePressed(context),
                tooltip: 'Excluir',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
