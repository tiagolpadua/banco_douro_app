import 'package:banco_douro_app/providers/account_provider.dart';
import 'package:banco_douro_app/providers/auth_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:banco_douro_app/services/account_service.dart';
import 'package:banco_douro_app/services/account_type_service.dart';
import 'package:banco_douro_app/services/auth_service.dart';
import 'package:banco_douro_app/data/repositories/account_local_repository.dart';

@GenerateMocks([
  AccountService,
  AccountTypeService,
  AuthService,
  AccountLocalRepository,
  AuthProvider,
  AccountProvider,
])
void main() {}
