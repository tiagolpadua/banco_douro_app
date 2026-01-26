import 'package:banco_douro_app/data/repositories/account_local_repository.dart';
import 'package:banco_douro_app/models/account.dart';
import 'package:banco_douro_app/models/account_type.dart';
import 'package:banco_douro_app/services/account_service.dart';
import 'package:banco_douro_app/services/account_type_service.dart';

class AccountViewModel {
  List<Account> _accounts = [];
  List<AccountType> _accountTypes = [];
  late AccountService _accountService;
  late AccountTypeService _accountTypeService;
  late AccountLocalRepository _accountLocalRepository;
  final isOnline = true;

  AccountViewModel() {
    _accountService = AccountService();
    _accountTypeService = AccountTypeService();
    _accountLocalRepository = AccountLocalRepository();
  }

  Future<void> loadAccounts() async {
    if (isOnline) {
      _accounts = await _accountService.getAll();
      await _accountLocalRepository.deleteAll();
      await _accountLocalRepository.insertAll(_accounts);
    } else {
      _accounts = await _accountLocalRepository.getAll();
    }
  }

  Future<void> loadAccountTypes() async {
    if (isOnline) {
      _accountTypes = await _accountTypeService.getAll();
    }
  }

  List<Account> get accounts => List.unmodifiable(_accounts);
  List<AccountType> get accountTypes => List.unmodifiable(_accountTypes);
}
