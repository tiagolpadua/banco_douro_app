import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final bool isVisible;
  final VoidCallback onToggleVisibility;

  const BalanceCard({
    required this.balance,
    required this.isVisible,
    required this.onToggleVisibility,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saldo disponivel',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: onToggleVisibility,
                child: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              isVisible
                  ? 'R\$ ${balance.toStringAsFixed(2)}'
                  : 'R\$ \u2022\u2022\u2022\u2022\u2022\u2022',
              key: ValueKey(isVisible),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Text.Rich para misturar estilos no limite
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Limite disponivel: ',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                TextSpan(
                  text: isVisible
                      ? 'R\$ 8.000,00'
                      : 'R\$ \u2022\u2022\u2022\u2022',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
