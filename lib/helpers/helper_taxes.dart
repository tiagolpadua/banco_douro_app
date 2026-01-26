import '../models/account.dart';

/// Calcula taxas baseado no tipo de conta (accountTypeId)
///
/// Nota: A logica de taxas deve ser ajustada conforme os tipos
/// de conta definidos no endpoint /accountTypes.
double calculateTaxesByAccount({
  required Account sender,
  required double amount,
}) {
  if (amount < 5000) return 0;

  if (sender.accountTypeId != null) {
    // Taxas baseadas no ID do tipo de conta
    switch (sender.accountTypeId) {
      case "1":
        return amount * 0.005; // 0.5%
      case "2":
        return amount * 0.0033; // 0.33%
      case "3":
        return amount * 0.0025; // 0.25%
      case "4":
        return amount * 0.0001; // 0.01%
      default:
        return amount * 0.001; // 0.1% padrao
    }
  } else {
    return 0.1;
  }
}
