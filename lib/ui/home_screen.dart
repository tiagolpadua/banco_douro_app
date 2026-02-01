import 'package:flutter/material.dart';
import '../models/account.dart';
import '../services/auth_service.dart';
import '../viewmodels/account_viewmodel.dart';
import 'styles/colors.dart';
import 'widgets/account_widget.dart';
import 'widgets/add_account_modal.dart';
import 'widgets/confirmation_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AccountViewModel _accountViewModel = AccountViewModel();
  final AuthService _authService = AuthService();
  List<Account> _listAccounts = [];

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
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Sair',
      content: 'Deseja realmente sair do sistema?',
      confirmText: 'Sair',
    );

    if (confirmed == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, 'login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.lightGrey,
        title: const Text("Sistema de gestão de contas"),
        actions: [
          IconButton(
            onPressed: _onLogoutPressed,
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
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
        backgroundColor: AppColor.orange,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: refreshGetAll,
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
        ),
      ),
    );
  }
}
