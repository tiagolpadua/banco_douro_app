import 'package:banco_douro_app/services/transaction_service.dart';
import 'package:flutter/material.dart';
import '/models/transaction.dart';
import 'theme/app_colors.dart';

/// Tela de transacoes com layout responsivo por orientacao.
/// Demonstra o uso de OrientationBuilder para adaptar o layout:
/// - Portrait: lista vertical com rodape de resumo (Column)
/// - Landscape: lista ao lado de painel lateral de resumo (Row)
///
/// Tambem demonstra ConstrainedBox para limitar a largura do painel
/// lateral, impedindo que ocupe espaco excessivo em telas grandes.
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TransactionService _transactionService = TransactionService();
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await _transactionService.getAll();
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  double get _totalAmount =>
      _transactions.fold(0.0, (sum, t) => sum + t.amount);

  double get _totalTaxes =>
      _transactions.fold(0.0, (sum, t) => sum + t.taxes);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transacoes'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))

          /// OrientationBuilder - reconstroi o widget sempre que a orientacao
          /// do dispositivo muda (portrait <-> landscape). Diferente de
          /// MediaQuery, responde especificamente a mudancas de orientacao
          /// e reconstroi apenas o sub-tree dentro do builder.
          : OrientationBuilder(
              builder: (context, orientation) {
                if (orientation == Orientation.landscape) {
                  return _buildLandscape();
                }
                return _buildPortrait();
              },
            ),
    );
  }

  /// Layout portrait: Column com lista expandida e rodape fixo.
  /// Em portrait ha mais espaco vertical, entao a lista ocupa o maximo
  /// e o resumo fica compacto no rodape.
  Widget _buildPortrait() {
    return Column(
      children: [
        Expanded(child: _buildTransactionList()),
        _buildSummaryFooter(),
      ],
    );
  }

  /// Layout landscape: Row com lista expandida e painel lateral.
  /// Em landscape ha mais espaco horizontal, entao aproveitamos com
  /// um painel lateral de resumo ao lado da lista.
  ///
  /// ConstrainedBox(maxWidth: 360) - impoe uma largura maxima ao painel
  /// lateral. Sem essa constraint, o painel poderia crescer excessivamente
  /// em telas muito largas (ex: tablet landscape), prejudicando o layout.
  Widget _buildLandscape() {
    return Row(
      children: [
        Expanded(child: _buildTransactionList()),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: _buildSummaryPanel(),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    if (_transactions.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma transacao encontrada',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        return _TransactionTile(transaction: transaction);
      },
    );
  }

  Widget _buildSummaryFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            label: 'Total movimentado',
            value: 'R\$ ${_totalAmount.toStringAsFixed(2)}',
            color: AppColors.primary,
          ),
          _SummaryItem(
            label: 'Total em taxas',
            value: 'R\$ ${_totalTaxes.toStringAsFixed(2)}',
            color: AppColors.negative,
          ),
          _SummaryItem(
            label: 'Quantidade',
            value: '${_transactions.length}',
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPanel() {
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          _SummaryPanelItem(
            icon: Icons.swap_horiz,
            label: 'Total movimentado',
            value: 'R\$ ${_totalAmount.toStringAsFixed(2)}',
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          _SummaryPanelItem(
            icon: Icons.receipt,
            label: 'Total em taxas',
            value: 'R\$ ${_totalTaxes.toStringAsFixed(2)}',
            color: AppColors.negative,
          ),
          const SizedBox(height: 16),
          _SummaryPanelItem(
            icon: Icons.format_list_numbered,
            label: 'Quantidade',
            value: '${_transactions.length}',
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.swap_horiz, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'De: ${transaction.senderAccountId.substring(0, 5)}  →  ${transaction.receiverAccountId.substring(0, 5)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Taxa: R\$ ${transaction.taxes.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'R\$ ${transaction.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SummaryPanelItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryPanelItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
