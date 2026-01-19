import 'package:banco_douro_app/data/repositories/account_local_repository.dart';
import 'package:banco_douro_app/models/account.dart';
import 'package:banco_douro_app/services/account_service.dart';

class AccountViewModel {
  List<Account> _accounts = [];
  late AccountService _accountService;
  late AccountLocalRepository _accountLocalRepository;
  final isOnline = true;

  AccountViewModel() {
    _accountService = AccountService();
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

  List<Account> get accounts => List.unmodifiable(_accounts);
}
