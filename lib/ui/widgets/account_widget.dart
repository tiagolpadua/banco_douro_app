import 'dart:math';

import 'package:flutter/material.dart';
import '/models/account.dart';
import '/models/account_type.dart';
import '/ui/styles/colors.dart';

class AccountWidget extends StatelessWidget {
  final Account account;
  final List<AccountType> accountTypes;

  const AccountWidget({
    super.key,
    required this.account,
    required this.accountTypes,
  });

  String _getAccountTypeDescription() {
    if (account.accountTypeId == null) return "Sem tipo definido";
    final type = accountTypes.where((t) => t.id == account.accountTypeId).firstOrNull;
    return type?.description ?? "Tipo desconhecido";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColor.lightOrange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
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
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
        ],
      ),
    );
  }
}
