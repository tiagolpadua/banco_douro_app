class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:3000';

  static String get accountsUrl => '$baseUrl/accounts';
  static String get transactionsUrl => '$baseUrl/transactions';
  static String get accountTypesUrl => '$baseUrl/accountTypes';
}
