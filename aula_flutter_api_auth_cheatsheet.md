# Flutter Cheatsheet - APIs e Autenticação

## Consumo de APIs REST com Autenticação

**Objetivo:** Referência rápida para acompanhamento da aula e consulta posterior.

---

## Índice

1. [PUT - Atualizar Recursos](#put---atualizar-recursos)
2. [DELETE - Remover Recursos](#delete---remover-recursos)
3. [Dialogs de Confirmação](#dialogs-de-confirmação)
4. [Autenticação com Login e Senha](#autenticação-com-login-e-senha)
5. [Token de Autenticação (JWT)](#token-de-autenticação-jwt)
6. [Tratamento de Erros de APIs](#tratamento-de-erros-de-apis)
7. [Recursos e Documentação](#recursos-e-documentação)

---

## PUT - Atualizar Recursos

### Requisição PUT Básica

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<bool> updateAccount(Account account) async {
  final response = await http.put(
    Uri.parse('http://localhost:3000/accounts/${account.id}'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(account.toMap()),
  );

  return response.statusCode == 200;
}
```

> Documentação: [http package](https://pub.dev/packages/http)

### PUT com Autenticação

```dart
Future<bool> updateAccount(Account account, String token) async {
  final response = await http.put(
    Uri.parse('$baseUrl/accounts/${account.id}'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: json.encode(account.toMap()),
  );

  if (response.statusCode != 200) {
    throw Exception('Falha ao atualizar: ${response.body}');
  }

  return true;
}
```

### Diferença PUT vs PATCH

| Método | Uso | Corpo da Requisição |
|--------|-----|---------------------|
| `PUT` | Substituição completa | Objeto inteiro |
| `PATCH` | Atualização parcial | Apenas campos alterados |

```dart
// PUT - envia objeto completo
body: json.encode(account.toMap())

// PATCH - envia apenas o que mudou
body: json.encode({'name': 'Novo Nome'})
```

---

## DELETE - Remover Recursos

### Requisição DELETE Básica

```dart
Future<bool> deleteAccount(String id) async {
  final response = await http.delete(
    Uri.parse('http://localhost:3000/accounts/$id'),
    headers: {'Content-Type': 'application/json'},
  );

  return response.statusCode == 200;
}
```

### DELETE com Autenticação

```dart
Future<bool> deleteAccount(String id, String token) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/accounts/$id'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Falha ao excluir');
  }

  return true;
}
```

### Códigos de Status DELETE

| Código | Significado |
|--------|-------------|
| `200` | Sucesso com corpo na resposta |
| `204` | Sucesso sem corpo (No Content) |
| `404` | Recurso não encontrado |
| `401` | Não autorizado |

---

## Dialogs de Confirmação

### AlertDialog Básico

```dart
Future<bool?> showConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Confirmação'),
      content: Text('Deseja realizar esta ação?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Confirmar'),
        ),
      ],
    ),
  );
}
```

> Documentação: [AlertDialog](https://api.flutter.dev/flutter/material/AlertDialog-class.html)

### Dialog Reutilizável

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
            style: TextStyle(
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

### Uso do Dialog

```dart
void _onDeletePressed() async {
  final confirmed = await showConfirmationDialog(
    context,
    title: 'Excluir Conta',
    content: 'Deseja realmente excluir esta conta?',
    confirmText: 'Excluir',
  );

  if (confirmed == true) {
    await deleteAccount(account.id);
    // Atualizar UI
  }
}
```

### Padrão: Sempre Confirmar Ações Destrutivas

```dart
// BOM - Pede confirmação antes de excluir
onPressed: () async {
  final confirmed = await showConfirmationDialog(context);
  if (confirmed == true) {
    await service.delete(id);
  }
}

// RUIM - Exclui direto sem confirmar
onPressed: () async {
  await service.delete(id);
}
```

---

## Autenticação com Login e Senha

### Estrutura do AuthService

```dart
class AuthService {
  static const String _tokenKey = 'accessToken';

  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode != 200) {
      throw Exception('Falha no login');
    }

    final data = json.decode(response.body);
    return data['accessToken'];
  }

  Future<String> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode != 201) {
      throw Exception('Falha no registro');
    }

    final data = json.decode(response.body);
    return data['accessToken'];
  }
}
```

### Endpoints de Autenticação (json-server-auth)

| Método | Endpoint | Body | Resposta |
|--------|----------|------|----------|
| POST | `/register` | `{email, password}` | `{accessToken, user}` |
| POST | `/login` | `{email, password}` | `{accessToken, user}` |

### Tela de Login

```dart
class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _onLoginPressed() async {
    setState(() => _isLoading = true);

    try {
      await _authService.login(
        _emailController.text,
        _passwordController.text,
      );
      Navigator.pushReplacementNamed(context, 'home');
    } catch (e) {
      // Mostrar erro
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextFormField(controller: _emailController),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _onLoginPressed,
            child: _isLoading
                ? CircularProgressIndicator()
                : Text('Entrar'),
          ),
        ],
      ),
    );
  }
}
```

---

## Token de Autenticação (JWT)

### Instalação do SharedPreferences

```yaml
# pubspec.yaml
dependencies:
  shared_preferences: ^2.2.2
```

```bash
flutter pub add shared_preferences
```

> Pacote: [pub.dev/packages/shared_preferences](https://pub.dev/packages/shared_preferences)

### Salvar Token

```dart
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('accessToken', token);
}
```

### Recuperar Token

```dart
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('accessToken');
}
```

### Verificar se Está Logado

```dart
Future<bool> isLoggedIn() async {
  final token = await getToken();
  return token != null && token.isNotEmpty;
}
```

### Logout (Remover Token)

```dart
Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('accessToken');
}
```

### Usar Token nas Requisições

```dart
Future<Map<String, String>> _getHeaders() async {
  final token = await getToken();
  return {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
}

Future<List<Account>> getAccounts() async {
  final headers = await _getHeaders();
  final response = await http.get(
    Uri.parse('$baseUrl/accounts'),
    headers: headers,
  );
  // ...
}
```

### Verificar Token no Startup

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authService = AuthService();
  final isLoggedIn = await authService.isLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: isLoggedIn ? 'home' : 'login',
      routes: {
        'login': (_) => LoginScreen(),
        'home': (_) => HomeScreen(),
      },
    );
  }
}
```

---

## Tratamento de Erros de APIs

### Exceções Customizadas

```dart
class UserNotFoundException implements Exception {
  final String message;
  UserNotFoundException([this.message = 'Usuário não encontrado']);
}

class TokenExpiredException implements Exception {
  final String message;
  TokenExpiredException([this.message = 'Token expirado']);
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Não autorizado']);
}

class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Erro no servidor']);
}
```

### Verificar Erros da API

```dart
void _verifyException(String responseBody) {
  final errorMessage = responseBody.toLowerCase();

  if (errorMessage.contains('jwt expired')) {
    throw TokenExpiredException();
  }
  if (errorMessage.contains('cannot find user')) {
    throw UserNotFoundException();
  }
  if (errorMessage.contains('unauthorized')) {
    throw UnauthorizedException();
  }

  throw ServerException(responseBody);
}
```

### Try-Catch com Múltiplas Exceções

```dart
Future<void> _onLoginPressed() async {
  try {
    await authService.login(email, password);
    Navigator.pushReplacementNamed(context, 'home');
  } on UserNotFoundException {
    // Usuário não existe - oferecer registro
    _offerRegistration();
  } on UnauthorizedException {
    // Senha incorreta
    _showError('Senha incorreta');
  } on SocketException {
    // Sem internet
    _showError('Verifique sua conexão');
  } catch (e) {
    // Erro genérico
    _showError('Erro inesperado');
  }
}
```

### Tratamento com catchError (Futures)

```dart
authService.login(email, password)
  .then((token) {
    Navigator.pushReplacementNamed(context, 'home');
  })
  .catchError((e) {
    _offerRegistration();
  }, test: (e) => e is UserNotFoundException)
  .catchError((e) {
    _showError(e.message);
  }, test: (e) => e is ServerException);
```

### Dialog de Erro

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
          Icon(Icons.warning, color: Colors.orange),
          SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
```

### Códigos HTTP Comuns

| Código | Significado | Ação Sugerida |
|--------|-------------|---------------|
| `200` | Sucesso | Processar resposta |
| `201` | Criado | Processar resposta |
| `400` | Bad Request | Validar dados enviados |
| `401` | Não Autorizado | Redirecionar para login |
| `403` | Proibido | Mostrar mensagem |
| `404` | Não Encontrado | Mostrar mensagem |
| `500` | Erro Servidor | Tentar novamente |

### Tratamento de Token Expirado

```dart
try {
  final accounts = await accountService.getAll();
} on TokenExpiredException {
  await authService.logout();
  Navigator.pushNamedAndRemoveUntil(
    context,
    'login',
    (route) => false,
  );
}
```

---

## json-server-auth

### Instalação

```bash
npm install -g json-server-auth
```

### Estrutura do db.json

```json
{
  "users": [],
  "accounts": [],
  "transactions": [],
  "accountTypes": []
}
```

### Arquivo routes.json (Permissões)

```json
{
  "users": 600,
  "accounts": 660,
  "transactions": 660,
  "accountTypes": 444
}
```

### Códigos de Permissão

| Código | Leitura | Escrita | Descrição |
|--------|---------|---------|-----------|
| `444` | Público | - | Somente leitura pública |
| `600` | Privado | Privado | Apenas dono acessa |
| `640` | Público | Privado | Lê público, escreve autenticado |
| `660` | Autenticado | Autenticado | Requer token |

### Executar Servidor

```bash
json-server-auth db.json --routes routes.json --port 3000
```

---

## Recursos e Documentação

### Documentação Oficial

| Recurso | Link |
|---------|------|
| http package | [pub.dev/packages/http](https://pub.dev/packages/http) |
| shared_preferences | [pub.dev/packages/shared_preferences](https://pub.dev/packages/shared_preferences) |
| json-server-auth | [npmjs.com/package/json-server-auth](https://www.npmjs.com/package/json-server-auth) |

### API Reference

| Classe | Link |
|--------|------|
| AlertDialog | [api.flutter.dev/flutter/material/AlertDialog](https://api.flutter.dev/flutter/material/AlertDialog-class.html) |
| showDialog | [api.flutter.dev/flutter/material/showDialog](https://api.flutter.dev/flutter/material/showDialog.html) |
| Navigator | [api.flutter.dev/flutter/widgets/Navigator](https://api.flutter.dev/flutter/widgets/Navigator-class.html) |

### HTTP Status Codes

| Recurso | Link |
|---------|------|
| MDN Web Docs | [developer.mozilla.org/en-US/docs/Web/HTTP/Status](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status) |
| HTTP Cats | [http.cat](https://http.cat/) |

---

## Quick Reference

| Ação | Código |
|------|--------|
| Requisição PUT | `http.put(uri, headers: {...}, body: json)` |
| Requisição DELETE | `http.delete(uri, headers: {...})` |
| Mostrar dialog | `showDialog(context: ctx, builder: ...)` |
| Fechar dialog com valor | `Navigator.pop(context, value)` |
| Salvar token | `prefs.setString('key', token)` |
| Recuperar token | `prefs.getString('key')` |
| Remover token | `prefs.remove('key')` |
| Header de auth | `'Authorization': 'Bearer $token'` |
| Lançar exceção | `throw MinhaException()` |
| Capturar específica | `on MinhaException catch (e) {...}` |

---

## Fluxo de Autenticação

```
App Inicia
    |
    v
Verifica token no SharedPreferences
    |
    +---> Token existe? ---> HomeScreen
    |
    +---> Não existe? ---> LoginScreen
                              |
                              v
                         Usuário digita email/senha
                              |
                              v
                         POST /login
                              |
              +---------------+---------------+
              |               |               |
              v               v               v
           Sucesso       Usuário não      Erro
              |          encontrado         |
              v               |             v
         Salvar token    Oferecer      Mostrar erro
              |          registro
              v               |
         HomeScreen      POST /register
                              |
                              v
                         Salvar token
                              |
                              v
                         HomeScreen
```

---

## Fluxo de Requisição Autenticada

```
Ação do Usuário (ex: editar conta)
         |
         v
Recuperar token do SharedPreferences
         |
         v
Montar headers com Authorization
         |
         v
Fazer requisição (PUT/DELETE)
         |
         +---> 200: Sucesso --> Atualizar UI
         |
         +---> 401: Não autorizado --> Verificar token
         |                                   |
         |                           Token expirado?
         |                                   |
         |                           Logout e ir para Login
         |
         +---> 4xx/5xx: Erro --> Mostrar mensagem
```

---

## Checklist da Aula

- [ ] Fazer requisição PUT para atualizar recurso
- [ ] Fazer requisição DELETE para remover recurso
- [ ] Criar dialog de confirmação reutilizável
- [ ] Usar dialog antes de ações destrutivas
- [ ] Implementar login com email e senha
- [ ] Implementar registro de novo usuário
- [ ] Salvar token com SharedPreferences
- [ ] Recuperar e verificar token no startup
- [ ] Enviar token no header Authorization
- [ ] Implementar logout (remover token)
- [ ] Criar exceções customizadas
- [ ] Tratar erros específicos da API
- [ ] Mostrar mensagens de erro amigáveis
- [ ] Redirecionar para login quando token expira
- [ ] Configurar json-server-auth

---

**Próxima Aula:** A definir
