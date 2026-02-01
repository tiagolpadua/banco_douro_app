# Plano Live Coding - Banco Douro App

## Objetivo

Implementar funcionalidades de API avançadas no projeto `banco_douro_app` para uma sessão de live coding de 2 horas.

## Temas a serem cobertos

1. Alterar recursos com PUT
2. Deletar recursos com DELETE
3. Utilizar dialogs de confirmação
4. Fazer autenticação com login e senha
5. Utilizar token de autenticação
6. Lidar com erros comuns de APIs

## Projeto de Referência

`flutter_webapi_second_course-aula05`

---

## Estrutura da Sessão (2 horas)

### Bloco 1: Configuração e Autenticação (40 min)

#### 1.1 Preparação (5 min)

- Revisar estrutura atual do projeto
- Adicionar dependência `shared_preferences` no `pubspec.yaml`

#### 1.2 Criar AuthService (15 min)

**Arquivo:** `lib/services/auth_service.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  static const String _tokenKey = 'accessToken';
  static const String _userIdKey = 'userId';
  static const String _emailKey = 'email';

  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/login'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      if (error.toString().contains('Cannot find user')) {
        throw UserNotFoundException();
      }
      throw HttpException(response.body);
    }

    return _saveToken(response.body);
  }

  Future<String> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/register'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode != 201) {
      throw HttpException(response.body);
    }

    return _saveToken(response.body);
  }

  Future<String> _saveToken(String body) async {
    final prefs = await SharedPreferences.getInstance();
    final map = json.decode(body);

    await prefs.setString(_tokenKey, map['accessToken']);
    await prefs.setString(_userIdKey, map['user']['id'].toString());
    await prefs.setString(_emailKey, map['user']['email']);

    return map['accessToken'];
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_emailKey);
  }
}

class UserNotFoundException implements Exception {}
class HttpException implements Exception {
  final String message;
  HttpException(this.message);
}
```

#### 1.3 Atualizar LoginScreen (20 min)

**Arquivo:** `lib/ui/login_screen.dart`

- Integrar `AuthService`
- Validar campos email/senha
- Chamar API de login
- Tratar erros (usuário não encontrado, erro genérico)
- Oferecer opção de registro se usuário não existir
- Navegar para home após sucesso

---

### Bloco 2: Token e Headers de Autenticação (25 min)

#### 2.1 Atualizar AccountService com Token (15 min)

**Arquivo:** `lib/services/account_service.dart`

Modificar todos os métodos para incluir token:

```dart
Future<String> _getAuthHeader() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken') ?? '';
  return 'Bearer $token';
}

Future<List<Account>> getAll() async {
  final token = await _getAuthHeader();
  final response = await client.get(
    Uri.parse(ApiConfig.accountsUrl),
    headers: {
      'Content-type': 'application/json',
      'Authorization': token,
    },
  );
  // ... resto do código
}
```

#### 2.2 Verificar Token na Inicialização (10 min)

**Arquivo:** `lib/main.dart`

```dart
Future<bool> verifyToken() async {
  final authService = AuthService();
  return await authService.isLoggedIn();
}

// Definir rota inicial baseada no token
initialRoute: (await verifyToken()) ? 'home' : 'login',
```

---

### Bloco 3: PUT - Editar Contas (25 min)

#### 3.1 Criar EditAccountModal (15 min)

**Arquivo:** `lib/ui/widgets/edit_account_modal.dart`

Similar ao `AddAccountModal`, mas:

- Recebe `Account` existente como parâmetro
- Preenche campos com valores atuais
- Chama `AccountService.updateAccount()` no submit

#### 3.2 Adicionar Botão de Edição (10 min)

**Arquivo:** `lib/ui/widgets/account_widget.dart`

- Adicionar `IconButton` com ícone de edição
- Ao clicar, abrir `EditAccountModal`
- Passar callback para atualizar lista após edição

---

### Bloco 4: DELETE e Dialogs de Confirmação (20 min)

#### 4.1 Criar Dialog de Confirmação Reutilizável (8 min)

**Arquivo:** `lib/ui/widgets/confirmation_dialog.dart`

```dart
Future<bool?> showConfirmationDialog(
  BuildContext context, {
  String title = 'Atenção!',
  String content = 'Deseja realizar esta operação?',
  String confirmText = 'Confirmar',
  String cancelText = 'Cancelar',
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            confirmText,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
```

#### 4.2 Implementar DELETE no AccountService (5 min)

**Arquivo:** `lib/services/account_service.dart`

```dart
Future<bool> deleteAccount(String id) async {
  final token = await _getAuthHeader();
  final response = await client.delete(
    Uri.parse('${ApiConfig.accountsUrl}/$id'),
    headers: {
      'Content-type': 'application/json',
      'Authorization': token,
    },
  );

  if (response.statusCode != 200) {
    _verifyException(response.body);
  }

  return true;
}
```

#### 4.3 Adicionar Botão de Exclusão com Confirmação (7 min)

**Arquivo:** `lib/ui/widgets/account_widget.dart`

```dart
void _deleteAccount(BuildContext context) async {
  final confirmed = await showConfirmationDialog(
    context,
    title: 'Excluir Conta',
    content: 'Deseja realmente excluir a conta de ${account.name}?',
    confirmText: 'Excluir',
  );

  if (confirmed == true) {
    try {
      await AccountService().deleteAccount(account.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta excluída com sucesso!')),
      );
      onDelete?.call(); // Callback para atualizar lista
    } catch (e) {
      // Tratar erro
    }
  }
}
```

---

### Bloco 5: Tratamento de Erros (10 min)

#### 5.1 Criar Dialog de Exceção (5 min)

**Arquivo:** `lib/ui/widgets/exception_dialog.dart`

```dart
void showExceptionDialog(
  BuildContext context, {
  required String content,
  String title = 'Ocorreu um problema',
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
```

#### 5.2 Criar Exceções Customizadas (2 min)

**Arquivo:** `lib/exceptions/api_exceptions.dart`

```dart
class TokenExpiredException implements Exception {}
class UnauthorizedException implements Exception {}
class NotFoundException implements Exception {}
class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}
```

#### 5.3 Implementar Verificação de Erros (3 min)

**Arquivo:** `lib/services/account_service.dart`

```dart
void _verifyException(String responseBody) {
  final error = json.decode(responseBody);
  final errorMessage = error.toString();

  if (errorMessage.contains('jwt expired')) {
    throw TokenExpiredException();
  }
  if (errorMessage.contains('jwt malformed')) {
    throw UnauthorizedException();
  }

  throw ServerException(errorMessage);
}
```

---

## Arquivos a Modificar/Criar

### Novos Arquivos

| Arquivo                                   | Descrição                          |
| ----------------------------------------- | ---------------------------------- |
| `lib/services/auth_service.dart`          | Serviço de autenticação            |
| `lib/ui/widgets/confirmation_dialog.dart` | Dialog de confirmação reutilizável |
| `lib/ui/widgets/exception_dialog.dart`    | Dialog de erro                     |
| `lib/ui/widgets/edit_account_modal.dart`  | Modal para editar conta            |
| `lib/exceptions/api_exceptions.dart`      | Exceções customizadas              |

### Arquivos a Modificar

| Arquivo                              | Alterações                                     |
| ------------------------------------ | ---------------------------------------------- |
| `pubspec.yaml`                       | Adicionar `shared_preferences`                 |
| `lib/main.dart`                      | Verificar token no startup                     |
| `lib/ui/login_screen.dart`           | Integrar AuthService                           |
| `lib/services/account_service.dart`  | Adicionar token em headers, implementar DELETE |
| `lib/ui/widgets/account_widget.dart` | Adicionar botões edit/delete                   |
| `lib/ui/home_screen.dart`            | Atualizar callbacks, logout funcional          |

---

## Verificação/Testes

1. **Login:**
   - Testar login com credenciais válidas
   - Testar login com usuário inexistente (deve oferecer registro)
   - Verificar persistência do token após fechar app

2. **PUT:**
   - Editar nome de uma conta
   - Verificar atualização na lista

3. **DELETE:**
   - Excluir conta e verificar dialog de confirmação
   - Cancelar exclusão e verificar que conta permanece
   - Confirmar exclusão e verificar remoção da lista

4. **Erros:**
   - Desligar servidor e verificar mensagem de erro
   - Usar token expirado e verificar tratamento

---

## Dependências Necessárias

```yaml
# Adicionar ao pubspec.yaml
dependencies:
  shared_preferences: ^2.2.2
```

---

## Ordem de Implementação Sugerida

1. Adicionar dependência shared_preferences
2. Criar AuthService
3. Atualizar LoginScreen
4. Verificar token no main.dart
5. Atualizar AccountService com headers de token
6. Criar confirmation_dialog.dart
7. Implementar DELETE no AccountService
8. Criar exception_dialog.dart e api_exceptions.dart
9. Criar EditAccountModal
10. Atualizar AccountWidget com botões edit/delete
11. Testar fluxo completo
