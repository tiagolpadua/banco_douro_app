import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TransactionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final double amount;
  final IconData icon;

  const TransactionTile({
    required this.title,
    required this.subtitle,
    required this.amount,
    this.icon = Icons.receipt_long,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = amount >= 0;
    final amountColor = isPositive ? AppColors.positive : AppColors.negative;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icone da transacao com fundo colorido
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: amountColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Titulo e subtitulo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Valor com cor semantica
          Text(
            '${isPositive ? '+' : '-'} R\$ ${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
