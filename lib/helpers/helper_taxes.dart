import '../models/account.dart';

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

  final rate = TaxConfig.taxRates[accountType] ?? TaxConfig.taxRates['BRIGADEIRO']!;
  return amount * rate;
}
