import 'package:banco_douro_app/services/auth_service.dart';
import 'package:banco_douro_app/viewmodels/account_viewmodel.dart';
import 'package:flutter/material.dart';
import '/models/account.dart';
import '/ui/widgets/account_widget.dart';
import '/ui/widgets/add_account_modal.dart';
import 'theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AccountViewModel _accountViewModel = AccountViewModel();
  List<Account> _listAccounts = [];
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    refreshGetAll();
  }

  Future<void> refreshGetAll() async {
    await _accountViewModel.loadAccounts();
    await _accountViewModel.loadAccountTypes();
    setState(() {
      _listAccounts = _accountViewModel.accounts;
    });
  }

  Future<void> _onLogoutPressed() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, 'login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
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
              child: ListView.builder(
                itemCount: _listAccounts.length,
                itemBuilder: (context, index) {
                  Account account = _listAccounts[index];
                  return AccountWidget(
                    account: account,
                    accountTypes: _accountViewModel.accountTypes,
                    onUpdate: refreshGetAll,
                    onDelete: refreshGetAll,
                  );
                },
              ),
            ),
          ),
        ],
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
          refreshGetAll();
        },
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
