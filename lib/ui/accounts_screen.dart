import 'package:banco_douro_app/viewmodels/account_viewmodel.dart';
import 'package:flutter/material.dart';
import '/models/account.dart';
import '/ui/widgets/account_widget.dart';
import '/ui/widgets/add_account_modal.dart';
import 'theme/app_colors.dart';

/// Tela de contas com layout responsivo por largura.
/// Demonstra como adaptar a apresentacao dos mesmos dados conforme
/// a largura disponivel, usando MediaQuery e breakpoints:
/// - Celular (< 600px): lista vertical com ListView.builder
/// - Tablet (>= 600px): grid de cards com GridView.builder
class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final AccountViewModel _accountViewModel = AccountViewModel();
  List<Account> _accounts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _accountViewModel.loadAccounts();
    await _accountViewModel.loadAccountTypes();
    setState(() {
      _accounts = _accountViewModel.accounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// MediaQuery.of(context).size.width - obtem a largura actual da tela.
    /// Usado como breakpoint para decidir entre lista e grid.
    /// 600px e o breakpoint padrao Material Design para tablets.
    final width = MediaQuery.of(context).size.width;
    final useGrid = width >= 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Contas'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AddAccountModal(),
          );
          _loadData();
        },
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      /// Alterna entre _buildList() e _buildGrid() com base no breakpoint.
      /// Ambos usam o mesmo AccountWidget - o layout muda mas o componente
      /// e reutilizado, demonstrando separacao entre dados e apresentacao.
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: useGrid ? _buildGrid() : _buildList(),
      ),
    );
  }

  /// Layout para celular: ListView.builder vertical.
  /// Cada item ocupa toda a largura disponivel.
  Widget _buildList() {
    return ListView.builder(
      itemCount: _accounts.length,
      itemBuilder: (context, index) {
        return AccountWidget(
          account: _accounts[index],
          accountTypes: _accountViewModel.accountTypes,
          onUpdate: _loadData,
          onDelete: _loadData,
        );
      },
    );
  }

  /// Layout para tablet: GridView.builder com colunas responsivas.
  /// - >= 900px: 3 colunas (tablet landscape)
  /// - >= 600px: 2 colunas (tablet portrait)
  ///
  /// childAspectRatio: 2.2 - controla a proporcao largura/altura de cada
  /// celula. Valores > 1 criam celulas mais largas que altas, adequado
  /// para cards com informacao horizontal.
  Widget _buildGrid() {
    final width = MediaQuery.of(context).size.width;
    final columns = width >= 900 ? 3 : 2;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: _accounts.length,
      itemBuilder: (context, index) {
        return AccountWidget(
          account: _accounts[index],
          accountTypes: _accountViewModel.accountTypes,
          onUpdate: _loadData,
          onDelete: _loadData,
        );
      },
    );
  }
}
