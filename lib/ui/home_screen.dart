import 'package:banco_douro_app/viewmodels/account_viewmodel.dart';
import 'package:flutter/material.dart';

import '/models/account.dart';
import '/ui/widgets/account_widget.dart';
import '/ui/widgets/add_account_modal.dart';
import 'styles/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AccountViewModel _accountViewModel = AccountViewModel();
  List<Account> _listAccounts = [];

  _HomeScreenState() {
    refreshGetAll();
  }

  Future<void> refreshGetAll() async {
    await _accountViewModel.loadAccounts();
    setState(() {
      _listAccounts = _accountViewModel.accounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Rebuild HomeScreen...");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.lightGrey,
        title: const Text("Sistema de gestão de contas"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, "login");
            },
            icon: const Icon(Icons.logout),
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
                child: ListView.builder(
                  itemCount: _listAccounts.length,
                  itemBuilder: (context, index) {
                    Account account = _listAccounts[index];
                    return AccountWidget(account: account);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
