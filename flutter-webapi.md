# Flutter com WebAPI: Integrando sua Aplicacao

Este documento apresenta os conceitos fundamentais para integrar aplicacoes Flutter com Web APIs, utilizando o projeto **Banco Douro App** como exemplo pratico.

---

## Sumario

1. [O que e uma Web API](#1-o-que-e-uma-web-api)
2. [REST, RESTful e JSON](#2-rest-restful-e-json)
3. [UUID - Identificadores Unicos](#3-uuid---identificadores-unicos)
4. [Biblioteca HTTP para Requisicoes](#4-biblioteca-http-para-requisicoes)
5. [Interceptadores e Loggers](#5-interceptadores-e-loggers)
6. [Requisicao GET - Buscando Dados](#6-requisicao-get---buscando-dados)
7. [Requisicao POST - Salvando Dados](#7-requisicao-post---salvando-dados)
8. [Fluxo Completo na Aplicacao](#8-fluxo-completo-na-aplicacao)

---

## 1. O que e uma Web API

### Definicao

Uma **Web API** (Application Programming Interface) e um conjunto de endpoints (URLs) que permitem a comunicacao entre sistemas atraves do protocolo HTTP. Ela funciona como um "contrato" que define como aplicacoes podem trocar dados pela internet.

### Analogia

Pense em um restaurante:
- **Cliente (App Flutter)**: Faz pedidos
- **Garcom (Web API)**: Recebe pedidos e traz respostas
- **Cozinha (Servidor/Banco de Dados)**: Processa e prepara os dados

### Exemplo no Projeto

No Banco Douro App, utilizamos o **json-server** como Web API de desenvolvimento:

```bash
# Iniciando o servidor (pasta data/)
json-server --watch db.json --host 0.0.0.0
```

O arquivo `data/db.json` define os dados disponiveis:

```json
{
  "accounts": [
    {
      "id": "ID001",
      "name": "Ricarth",
      "lastName": "Lima",
      "balance": 113,
      "accountTypeId": "1"
    },
    {
      "id": "ID002",
      "name": "Ana",
      "lastName": "Silva",
      "balance": 250,
      "accountTypeId": "1"
    }
  ],
  "accountTypes": [
    {
      "id": "1",
      "description": "Corrente"
    },
    {
      "id": "2",
      "description": "Poupanca"
    }
  ]
}
```

### Endpoints Gerados Automaticamente

| Metodo | Endpoint | Descricao |
|--------|----------|-----------|
| GET | `/accounts` | Lista todas as contas |
| GET | `/accounts/:id` | Busca conta por ID |
| POST | `/accounts` | Cria nova conta |
| PUT | `/accounts/:id` | Atualiza conta |
| DELETE | `/accounts/:id` | Remove conta |

---

## 2. REST, RESTful e JSON

### REST (Representational State Transfer)

REST e um estilo arquitetural para sistemas distribuidos. Define principios para comunicacao entre cliente e servidor:

1. **Stateless**: Cada requisicao contem todas as informacoes necessarias
2. **Client-Server**: Separacao clara entre cliente e servidor
3. **Uniform Interface**: URLs padronizadas para recursos
4. **Cacheable**: Respostas podem ser cacheadas

### RESTful

Uma API e considerada **RESTful** quando segue os principios REST corretamente:

| Recurso | URL | Metodos HTTP |
|---------|-----|--------------|
| Contas | `/accounts` | GET, POST |
| Conta especifica | `/accounts/{id}` | GET, PUT, DELETE |
| Tipos de conta | `/accountTypes` | GET |

### JSON (JavaScript Object Notation)

JSON e o formato padrao para troca de dados em APIs REST. E leve, legivel e facil de processar.

**Exemplo de JSON retornado pela API:**

```json
{
  "id": "ID001",
  "name": "Ricarth",
  "lastName": "Lima",
  "balance": 113,
  "accountTypeId": "1"
}
```

### Serializacao e Deserializacao em Dart

No Flutter, convertemos JSON para objetos Dart e vice-versa:

**Arquivo: `lib/models/account.dart`**

```dart
import 'dart:convert';

class Account {
  String id;
  String name;
  String lastName;
  double balance;
  String? accountTypeId;

  Account({
    required this.id,
    required this.name,
    required this.lastName,
    required this.balance,
    this.accountTypeId,
  });

  // DESERIALIZACAO: JSON/Map -> Objeto Dart
  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'].toString(),
      name: map['name'] as String,
      lastName: map['lastName'] as String,
      balance: (map['balance'] is int)
          ? (map['balance'] as int).toDouble()
          : map['balance'] as double,
      accountTypeId: (map['accountTypeId'] != null)
          ? map['accountTypeId'].toString()
          : null,
    );
  }

  // SERIALIZACAO: Objeto Dart -> Map/JSON
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'lastName': lastName,
      'balance': balance,
      'accountTypeId': accountTypeId,
    };
  }

  // Converte para String JSON
  String toJson() => json.encode(toMap());

  // Cria objeto a partir de String JSON
  factory Account.fromJson(String source) =>
      Account.fromMap(json.decode(source) as Map<String, dynamic>);
}
```

---

## 3. UUID - Identificadores Unicos

### O que e UUID

**UUID** (Universally Unique Identifier) e um identificador de 128 bits usado para garantir unicidade global. Formato: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

### Por que usar UUID?

1. **Unicidade garantida**: Praticamente impossivel gerar duplicatas
2. **Geracao no cliente**: Nao precisa do servidor para criar IDs
3. **Seguranca**: IDs nao sao sequenciais (mais dificil de adivinhar)
4. **Distribuido**: Varios sistemas podem gerar IDs sem conflito

### Versoes de UUID

- **v1**: Baseado em timestamp + MAC address
- **v4**: Totalmente aleatorio (mais comum)

### Configuracao no Flutter

**Arquivo: `pubspec.yaml`**

```yaml
dependencies:
  uuid: ^4.5.2
```

### Uso no Projeto

**Arquivo: `lib/ui/widgets/add_account_modal.dart`**

```dart
import 'package:uuid/uuid.dart';

Future<void> onButtonSendClicked() async {
  // Gerando UUID v1 (baseado em timestamp)
  Account account = Account(
    id: const Uuid().v1(),  // Ex: "622ee610-fa4a-11f0-bf0e-f3bd64eaa06e"
    name: _nameController.text,
    lastName: _lastNameController.text,
    balance: 0,
    accountTypeId: _selectedAccountTypeId,
  );

  await AccountService().addAccount(account);
}
```

---

## 4. Biblioteca HTTP para Requisicoes

### Configuracao

**Arquivo: `pubspec.yaml`**

```yaml
dependencies:
  http: ^1.6.0
  http_interceptor: ^2.0.0  # Para interceptadores
  logger: ^2.0.2            # Para logging formatado
```

Apos adicionar, execute:

```bash
flutter pub get
```

### Importacao

```dart
import 'package:http/http.dart' as http;
```

### Estrutura do Service

**Arquivo: `lib/services/account_service.dart`**

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import '../models/account.dart';
import 'http_interceptors.dart';

class AccountService {
  // URL base da API
  // NOTA: 10.0.2.2 e o localhost do host visto pelo emulador Android
  static const String url = "http://10.0.2.2:3000/";
  static const String resource = "accounts/";

  // Cliente HTTP com interceptador
  http.Client client = InterceptedClient.build(
    interceptors: [LoggingInterceptor()],
  );

  // Helpers para construcao de URLs
  String getURL() {
    return "$url$resource";
  }

  Uri getUri() {
    return Uri.parse(getURL());
  }
}
```

### Endereco do Emulador

| Ambiente | Endereco do localhost |
|----------|----------------------|
| Emulador Android | `10.0.2.2` |
| Simulador iOS | `localhost` ou `127.0.0.1` |
| Dispositivo fisico | IP da maquina na rede |

---

## 5. Interceptadores e Loggers

### O que sao Interceptadores?

Interceptadores sao middlewares que capturam requisicoes e respostas HTTP automaticamente. Permitem adicionar logica transversal como:

- **Logging**: Registrar todas as requisicoes
- **Autenticacao**: Adicionar tokens automaticamente
- **Cache**: Armazenar respostas
- **Retry**: Tentar novamente em caso de falha

### Configurando o Interceptador de Logging

**Arquivo: `lib/services/http_interceptors.dart`**

```dart
import 'package:http_interceptor/http_interceptor.dart';
import 'package:logger/logger.dart';

/// Interceptador de Logging
///
/// Interceptadores permitem capturar requisicoes e respostas HTTP
/// automaticamente, util para debug e monitoramento.
class LoggingInterceptor extends InterceptorContract {
  // Logger com formatacao bonita no console
  Logger logger = Logger(printer: PrettyPrinter(methodCount: 0));

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    // Executado ANTES de cada requisicao ser enviada
    logger.t("Requisicao para: ${request.url}\n${request.headers}");
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({required BaseResponse response}) async {
    // Executado APOS cada resposta ser recebida

    // Codigos 2xx indicam sucesso (200, 201, 204, etc.)
    if (response.statusCode ~/ 100 == 2) {
      logger.i(
        "Resposta de ${response.request?.url}\n"
        "Status: ${response.statusCode}",
      );
    } else {
      logger.e(
        "Erro de ${response.request?.url}\n"
        "Status: ${response.statusCode}",
      );
    }
    return response;
  }
}
```

### Niveis de Log

O pacote `logger` oferece diferentes niveis:

| Metodo | Nivel | Uso |
|--------|-------|-----|
| `logger.t()` | Trace | Detalhes minuciosos |
| `logger.d()` | Debug | Informacoes de debug |
| `logger.i()` | Info | Informacoes gerais |
| `logger.w()` | Warning | Avisos |
| `logger.e()` | Error | Erros |

### Aplicando o Interceptador

**Arquivo: `lib/services/account_service.dart`**

```dart
import 'package:http_interceptor/http_interceptor.dart';
import 'http_interceptors.dart';

class AccountService {
  // Cliente HTTP COM interceptador
  http.Client client = InterceptedClient.build(
    interceptors: [LoggingInterceptor()],
  );

  // Todas as requisicoes feitas com 'client' serao interceptadas
}
```

### Saida no Console

```
┌───────────────────────────────────────────────────────────────
│ Requisicao para: http://10.0.2.2:3000/accounts
│ {content-type: application/json}
└───────────────────────────────────────────────────────────────

┌───────────────────────────────────────────────────────────────
│ Resposta de http://10.0.2.2:3000/accounts
│ Status: 200
└───────────────────────────────────────────────────────────────
```

---

## 6. Requisicao GET - Buscando Dados

### Conceito

A requisicao **GET** e usada para buscar dados do servidor. E uma operacao de **leitura** que nao modifica dados.

### Implementacao no Service

**Arquivo: `lib/services/account_service.dart`**

```dart
/// Busca todas as contas - GET /accounts
Future<List<Account>> getAll() async {
  // 1. Faz a requisicao GET
  http.Response response = await client.get(getUri());

  // 2. Verifica se foi bem-sucedida
  if (response.statusCode != 200) {
    throw Exception("Falha ao buscar contas: ${response.statusCode}");
  }

  // 3. Converte JSON para lista de objetos
  List<Account> result = [];

  // Decodifica o body da resposta (JSON -> List<dynamic>)
  List<dynamic> jsonList = json.decode(response.body);

  // Converte cada Map para objeto Account
  for (var jsonMap in jsonList) {
    result.add(Account.fromMap(jsonMap));
  }

  return result;
}
```

### Codigos de Status HTTP para GET

| Codigo | Significado |
|--------|-------------|
| 200 | OK - Dados retornados com sucesso |
| 404 | Not Found - Recurso nao encontrado |
| 500 | Internal Server Error - Erro no servidor |

### Integracao com ViewModel

**Arquivo: `lib/viewmodels/account_viewmodel.dart`**

```dart
class AccountViewModel {
  List<Account> _accounts = [];
  late AccountService _accountService;

  AccountViewModel() {
    _accountService = AccountService();
  }

  Future<void> loadAccounts() async {
    // Chama o service para buscar dados da API
    _accounts = await _accountService.getAll();
  }

  // Getter expoe dados de forma imutavel
  List<Account> get accounts => List.unmodifiable(_accounts);
}
```

### Exibindo Dados na UI

**Arquivo: `lib/ui/home_screen.dart`**

```dart
class _HomeScreenState extends State<HomeScreen> {
  final AccountViewModel _accountViewModel = AccountViewModel();
  List<Account> _listAccounts = [];

  @override
  void initState() {
    super.initState();
    refreshGetAll();  // Carrega dados ao iniciar a tela
  }

  Future<void> refreshGetAll() async {
    // 1. Carrega dados via ViewModel
    await _accountViewModel.loadAccounts();

    // 2. Atualiza estado e reconstroi UI
    setState(() {
      _listAccounts = _accountViewModel.accounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _listAccounts.length,
        itemBuilder: (context, index) {
          Account account = _listAccounts[index];
          return AccountWidget(account: account);
        },
      ),
    );
  }
}
```

### Fluxo Completo do GET

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐     ┌─────────┐
│  HomeScreen │ --> │  ViewModel   │ --> │   Service   │ --> │   API   │
│  initState  │     │ loadAccounts │     │   getAll    │     │  GET /  │
└─────────────┘     └──────────────┘     └─────────────┘     └─────────┘
       │                   │                    │                  │
       │                   │                    │    JSON Response │
       │                   │                    │<-----------------│
       │                   │   List<Account>    │
       │                   │<-------------------│
       │   accounts        │
       │<------------------│
       │
       ▼
   setState()
   Rebuild UI
```

---

## 7. Requisicao POST - Salvando Dados

### Conceito

A requisicao **POST** e usada para enviar dados ao servidor e criar novos recursos. E uma operacao de **escrita**.

### Implementacao no Service

**Arquivo: `lib/services/account_service.dart`**

```dart
/// Adiciona uma nova conta - POST /accounts
Future<bool> addAccount(Account account) async {
  // 1. Converte objeto para JSON
  String accountJSON = json.encode(account.toMap());

  // 2. Faz a requisicao POST
  http.Response response = await client.post(
    getUri(),
    headers: {'Content-type': 'application/json'},  // IMPORTANTE!
    body: accountJSON,
  );

  // 3. Verifica se foi criado (201 Created)
  if (response.statusCode == 201) {
    return true;
  }

  return false;
}
```

### Headers Importantes

| Header | Valor | Descricao |
|--------|-------|-----------|
| Content-Type | `application/json` | Indica que o body esta em JSON |
| Accept | `application/json` | Indica que espera JSON na resposta |
| Authorization | `Bearer {token}` | Para APIs autenticadas |

### Codigos de Status HTTP para POST

| Codigo | Significado |
|--------|-------------|
| 201 | Created - Recurso criado com sucesso |
| 400 | Bad Request - Dados invalidos |
| 409 | Conflict - Recurso ja existe |
| 422 | Unprocessable Entity - Validacao falhou |

### Uso na UI

**Arquivo: `lib/ui/widgets/add_account_modal.dart`**

```dart
class _AddAccountModalState extends State<AddAccountModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String? _selectedAccountTypeId;
  bool isLoading = false;

  Future<void> onButtonSendClicked() async {
    if (!isLoading) {
      // 1. Mostra loading
      setState(() {
        isLoading = true;
      });

      // 2. Coleta dados do formulario
      String name = _nameController.text;
      String lastName = _lastNameController.text;

      // 3. Cria objeto Account com UUID
      Account account = Account(
        id: const Uuid().v1(),  // Gera ID unico
        name: name,
        lastName: lastName,
        balance: 0,
        accountTypeId: _selectedAccountTypeId,
      );

      // 4. Envia para a API via Service
      await AccountService().addAccount(account);

      // 5. Fecha o modal
      closeModal();
    }
  }

  void closeModal() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // IMPORTANTE: Sempre liberar controllers
    _nameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}
```

### Fluxo Completo do POST

```
┌─────────────────┐     ┌─────────────┐     ┌─────────┐
│ AddAccountModal │ --> │   Service   │ --> │   API   │
│ onButtonSend    │     │ addAccount  │     │ POST /  │
└─────────────────┘     └─────────────┘     └─────────┘
       │                      │                  │
       │   Account object     │                  │
       │--------------------->│                  │
       │                      │   JSON body      │
       │                      │----------------->│
       │                      │                  │
       │                      │   201 Created    │
       │                      │<-----------------│
       │   true/false         │
       │<---------------------│
       │
       ▼
   closeModal()
   Atualiza lista
```

---

## 8. Fluxo Completo na Aplicacao

### Arquitetura em Camadas

```
┌─────────────────────────────────────────────────────────────┐
│                         UI LAYER                            │
│  ┌─────────────┐    ┌──────────────┐    ┌───────────────┐  │
│  │ HomeScreen  │    │ AccountWidget│    │AddAccountModal│  │
│  └─────────────┘    └──────────────┘    └───────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                     VIEWMODEL LAYER                         │
│                  ┌──────────────────┐                       │
│                  │  AccountViewModel │                       │
│                  └──────────────────┘                       │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      SERVICE LAYER                          │
│          ┌────────────────┐    ┌───────────────────┐       │
│          │ AccountService │    │AccountTypeService │       │
│          └────────────────┘    └───────────────────┘       │
│                        │                                    │
│                        ▼                                    │
│              ┌──────────────────┐                          │
│              │LoggingInterceptor│                          │
│              └──────────────────┘                          │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                       WEB API                               │
│              http://10.0.2.2:3000/accounts                  │
│                     (json-server)                           │
└─────────────────────────────────────────────────────────────┘
```

### Ciclo de Vida: Carregando Dados (GET)

```dart
// 1. HomeScreen inicia
@override
void initState() {
  super.initState();
  refreshGetAll();
}

// 2. Chama ViewModel
Future<void> refreshGetAll() async {
  await _accountViewModel.loadAccounts();
  setState(() {
    _listAccounts = _accountViewModel.accounts;
  });
}

// 3. ViewModel chama Service
Future<void> loadAccounts() async {
  _accounts = await _accountService.getAll();
}

// 4. Service faz requisicao HTTP
Future<List<Account>> getAll() async {
  http.Response response = await client.get(getUri());
  // Interceptor loga automaticamente
  // Converte JSON -> List<Account>
  return result;
}

// 5. UI reconstroi com setState()
```

### Ciclo de Vida: Salvando Dados (POST)

```dart
// 1. Usuario preenche formulario e clica "Adicionar"
onButtonSendClicked() async {
  // 2. Cria objeto com UUID
  Account account = Account(
    id: const Uuid().v1(),
    name: _nameController.text,
    // ...
  );

  // 3. Envia para API
  await AccountService().addAccount(account);

  // 4. Fecha modal
  closeModal();
}

// 5. HomeScreen detecta fechamento do modal
floatingActionButton: FloatingActionButton(
  onPressed: () async {
    await showModalBottomSheet(...);
    refreshGetAll();  // Recarrega lista atualizada
  },
)
```

### Resumo das Dependencias

**Arquivo: `pubspec.yaml`**

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Requisicoes HTTP
  http: ^1.6.0

  # Interceptadores HTTP
  http_interceptor: ^2.0.0

  # Logging formatado
  logger: ^2.0.2

  # Geracao de UUIDs
  uuid: ^4.5.2
```

---

## Checklist de Implementacao

- [ ] Adicionar dependencias no `pubspec.yaml`
- [ ] Criar modelo com `fromMap()` e `toMap()`
- [ ] Criar Service com cliente HTTP
- [ ] Implementar interceptador de logging
- [ ] Implementar metodo GET para buscar dados
- [ ] Implementar metodo POST para salvar dados
- [ ] Criar ViewModel para gerenciar estado
- [ ] Conectar UI ao ViewModel
- [ ] Tratar erros e exibir feedback ao usuario

---

## Referencias

- [Pacote http](https://pub.dev/packages/http)
- [Pacote http_interceptor](https://pub.dev/packages/http_interceptor)
- [Pacote logger](https://pub.dev/packages/logger)
- [Pacote uuid](https://pub.dev/packages/uuid)
- [json-server](https://github.com/typicode/json-server)
- [REST API Tutorial](https://restfulapi.net/)
