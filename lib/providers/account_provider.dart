import 'package:banco_douro_app/data/repositories/account_local_repository.dart';
import 'package:banco_douro_app/models/account.dart';
import 'package:banco_douro_app/models/account_type.dart';
import 'package:banco_douro_app/services/account_service.dart';
import 'package:banco_douro_app/services/account_type_service.dart';
import 'package:flutter/foundation.dart';

class AccountProvider extends ChangeNotifier {
  AccountProvider({
    AccountService? accountService,
    AccountLocalRepository? accountLocalRepository,
    AccountTypeService? accountTypeService,
  }) : _accountService = accountService ?? AccountService(),
       _accountLocalRepository =
           accountLocalRepository ?? AccountLocalRepository(),
       _accountTypeService = accountTypeService ?? AccountTypeService();

  final AccountService _accountService;
  final AccountLocalRepository _accountLocalRepository;
  final AccountTypeService _accountTypeService;

  List<Account> _accounts = [];
  List<AccountType> _accountTypes = [];
  bool _isLoading = false;
  bool _isLoadingAccountTypes = false;
  String? _error;
  bool _initialized = false;

  List<Account> get accounts => List.unmodifiable(_accounts);
  List<AccountType> get accountTypes => List.unmodifiable(_accountTypes);
  bool get isLoading => _isLoading;
  bool get isLoadingAccountTypes => _isLoadingAccountTypes;
  String? get error => _error;
  bool get hasData => _accounts.isNotEmpty || _accountTypes.isNotEmpty;
  double get totalBalance =>
      _accounts.fold(0, (total, account) => total + account.balance);

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;
    await Future.wait([loadAccountTypes(), loadAll()]);
  }

  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _accounts = await _accountService.getAll();
      await _accountLocalRepository.deleteAll();
      await _accountLocalRepository.insertAll(_accounts);
    } catch (_) {
      _accounts = await _accountLocalRepository.getAll();
      _error = 'Sem conexao com a API. Exibindo dados locais.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAccountTypes() async {
    _isLoadingAccountTypes = true;
    notifyListeners();

    try {
      _accountTypes = await _accountTypeService.getAll();
    } catch (_) {
      _accountTypes = [];
    } finally {
      _isLoadingAccountTypes = false;
      notifyListeners();
    }
  }

  Future<void> addAccount(Account account) async {
    final success = await _accountService.addAccount(account);
    if (!success) {
      throw Exception('Falha ao adicionar conta');
    }

    _accounts = [..._accounts, account];
    await _accountLocalRepository.insert(account);
    notifyListeners();
  }

  Future<void> deleteAccount(String id) async {
    final success = await _accountService.deleteAccount(id);
    if (!success) {
      throw Exception('Falha ao excluir conta');
    }

    _accounts = _accounts.where((account) => account.id != id).toList();
    await _accountLocalRepository.delete(id);
    notifyListeners();
  }

  void clearError() {
    if (_error == null) {
      return;
    }

    _error = null;
    notifyListeners();
  }

  /// Limpa todos os dados e permite que [initialize] seja chamado novamente.
  /// Deve ser chamado no logout para evitar que dados de uma sessão
  /// apareçam na próxima.
  void reset() {
    _initialized = false;
    _accounts = [];
    _accountTypes = [];
    _error = null;
    notifyListeners();
  }
}
