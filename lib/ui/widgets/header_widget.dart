import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HeaderWidget extends StatelessWidget {
  final String userName;
  final String agency;
  final String account;
  final VoidCallback? onLogout;

  const HeaderWidget({
    required this.userName,
    required this.agency,
    required this.account,
    this.onLogout,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 16, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text.Rich para misturar estilos: "Ola, " (normal) + nome (bold)
                    Text.rich(
                      TextSpan(
                        text: 'Ola, ',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text: '$userName!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ag $agency | Cc $account',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nenhuma notificacao no momento'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  if (onLogout != null)
                    IconButton(
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white70,
                      ),
                      onPressed: onLogout,
                      tooltip: 'Sair',
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
