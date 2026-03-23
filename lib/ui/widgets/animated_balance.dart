import 'package:banco_douro_app/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AnimatedBalance extends StatelessWidget {
  final double value;

  const AnimatedBalance({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOut,
      builder: (context, animatedValue, child) {
        return Text(
          'R\$ ${animatedValue.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        );
      },
    );
  }
}
