import 'package:banco_douro_app/data/repositories/account_local_repository.dart';
import 'package:banco_douro_app/models/account.dart';
import 'package:banco_douro_app/models/account_type.dart';
import 'package:banco_douro_app/services/account_service.dart';
import 'package:banco_douro_app/services/account_type_service.dart';

class AccountViewModel {
  List<Account> _accounts = [];
  List<AccountType> _accountTypes = [];

  final AccountService _accountService;
  final AccountLocalRepository _accountLocalRepository;
  final AccountTypeService _accountTypeService;

  AccountViewModel({
    AccountService? accountService,
    AccountLocalRepository? accountLocalRepository,
    AccountTypeService? accountTypeService,
  })  : _accountService = accountService ?? AccountService(),
        _accountLocalRepository = accountLocalRepository ?? AccountLocalRepository(),
        _accountTypeService = accountTypeService ?? AccountTypeService();

  Future<void> loadAccounts() async {
    try {
      _accounts = await _accountService.getAll();
      await _accountLocalRepository.deleteAll();
      await _accountLocalRepository.insertAll(_accounts);
    } catch (e) {
      _accounts = await _accountLocalRepository.getAll();
    }
  }

  List<Account> get accounts => List.unmodifiable(_accounts);

  List<AccountType> get accountTypes => List.unmodifiable(_accountTypes);

  Future<void> loadAccountTypes() async {
    _accountTypes = await _accountTypeService.getAll();
  }
}
