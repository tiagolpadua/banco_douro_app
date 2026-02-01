class UserNotFoundException implements Exception {
  final String message;
  UserNotFoundException([this.message = 'Usuário não encontrado']);

  @override
  String toString() => message;
}

class TokenExpiredException implements Exception {
  final String message;
  TokenExpiredException([this.message = 'Token expirado']);

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Não autorizado']);

  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException([this.message = 'Recurso não encontrado']);

  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Erro no servidor']);

  @override
  String toString() => message;
}

class HttpException implements Exception {
  final String message;
  HttpException([this.message = 'Erro de conexão']);

  @override
  String toString() => message;
}
