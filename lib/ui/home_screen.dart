import 'package:banco_douro_app/providers/account_provider.dart';
import 'package:banco_douro_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/ui/widgets/account_widget.dart';
import '/ui/widgets/add_account_modal.dart';
import 'theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().initialize();
    });
  }

  Future<void> _onLogoutPressed() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, 'login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<AccountProvider>(
        builder: (context, provider, child) => Column(
          children: [
            // Header com gradiente igual ao login
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sistema de gestão de contas",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Banco Douro",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white60,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: _onLogoutPressed,
                        icon: const Icon(Icons.logout, color: Colors.white),
                        tooltip: 'Sair',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Lista de contas
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: provider.isLoading && provider.accounts.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: provider.accounts.length,
                        itemBuilder: (context, index) {
                          final account = provider.accounts[index];
                          return AccountWidget(
                            account: account,
                            accountTypes: provider.accountTypes,
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return const AddAccountModal();
            },
          );
        },
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
