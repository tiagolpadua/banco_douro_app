import '../models/account.dart';
import '../exceptions/transaction_exceptions.dart';

class TaxConfig {
  static const double minimumTaxableAmount = 5000.0;
  static const double defaultTaxRate = 0.1;

  static const Map<String, double> taxRates = {
    'AMBROSIA': 0.005,
    'CANJICA': 0.0033,
    'PUDIM': 0.0025,
    'BRIGADEIRO': 0.0001,
  };
}

double calculateTaxesByAccount({
  required Account sender,
  required double amount,
}) {
  if (amount < TaxConfig.minimumTaxableAmount) {
    return 0;
  }

  final accountType = sender.accountType?.toUpperCase();
  if (accountType == null) {
    return TaxConfig.defaultTaxRate;
  }

  final rate =
      TaxConfig.taxRates[accountType] ?? TaxConfig.taxRates['BRIGADEIRO']!;
  return amount * rate;
}

void validateTransaction({
  required Account sender,
  required double amount,
}) {
  if (amount <= 0) {
    throw ArgumentError('O valor da transação deve ser positivo');
  }

  final tax = calculateTaxesByAccount(sender: sender, amount: amount);
  final totalNeeded = amount + tax;

  if (sender.balance < totalNeeded) {
    throw InsufficientFundsException(
      message:
          'Saldo insuficiente.\n'
          'Saldo atual: R\$ ${sender.balance.toStringAsFixed(2)}\n'
          'Necessário: R\$ ${totalNeeded.toStringAsFixed(2)} '
          '(R\$ ${amount.toStringAsFixed(2)} + R\$ ${tax.toStringAsFixed(2)} de imposto)',
      cause: sender,
      amount: amount,
      taxes: tax,
    );
  }
}
