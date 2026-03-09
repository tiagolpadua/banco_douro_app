import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:banco_douro_app/providers/auth_provider.dart';
import '../mocks/mocks.mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late AuthProvider provider;

  setUp(() {
    mockAuthService = MockAuthService();
    provider = AuthProvider(authService: mockAuthService);
  });

  group('AuthProvider — estado inicial', () {
    test('deve iniciar com isLoggedIn = false', () {
      expect(provider.isLoggedIn, isFalse);
    });

    test('deve iniciar sem erro', () {
      expect(provider.error, isNull);
    });
  });

  group('AuthProvider.init', () {
    test('deve definir isLoggedIn = true quando token existe', () async {
      when(mockAuthService.isLoggedIn()).thenAnswer((_) async => true);

      await provider.init();

      expect(provider.isLoggedIn, isTrue);
    });

    test('deve definir isLoggedIn = false quando não há token', () async {
      when(mockAuthService.isLoggedIn()).thenAnswer((_) async => false);

      await provider.init();

      expect(provider.isLoggedIn, isFalse);
    });
  });

  group('AuthProvider.login', () {
    test('deve retornar true e definir isLoggedIn = true em caso de sucesso',
        () async {
      when(
        mockAuthService.login('user@email.com', 'senha123'),
      ).thenAnswer((_) async => 'fake-token');

      final result = await provider.login('user@email.com', 'senha123');

      expect(result, isTrue);
      expect(provider.isLoggedIn, isTrue);
      expect(provider.error, isNull);
    });

    test('deve retornar false e definir error quando credenciais inválidas',
        () async {
      when(
        mockAuthService.login(any, any),
      ).thenThrow(Exception('Falha no login: 401'));

      final result = await provider.login('email@errado.com', 'senhaErrada');

      expect(result, isFalse);
      expect(provider.isLoggedIn, isFalse);
      expect(provider.error, isNotNull);
    });

    test('deve limpar erro anterior antes de novo login', () async {
      // Primeiro login com erro
      when(
        mockAuthService.login(any, any),
      ).thenThrow(Exception('Erro'));
      await provider.login('email', 'senha');
      expect(provider.error, isNotNull);

      // Segundo login com sucesso
      when(
        mockAuthService.login('correto@email.com', 'correta'),
      ).thenAnswer((_) async => 'token');
      await provider.login('correto@email.com', 'correta');

      expect(provider.error, isNull);
    });
  });

  group('AuthProvider.logout', () {
    test('deve definir isLoggedIn = false após logout', () async {
      when(
        mockAuthService.login(any, any),
      ).thenAnswer((_) async => 'token');
      await provider.login('user@email.com', 'senha');
      expect(provider.isLoggedIn, isTrue);

      when(mockAuthService.logout()).thenAnswer((_) async {});
      await provider.logout();

      expect(provider.isLoggedIn, isFalse);
    });

    test('deve chamar authService.logout()', () async {
      when(mockAuthService.logout()).thenAnswer((_) async {});

      await provider.logout();

      verify(mockAuthService.logout()).called(1);
    });
  });

  group('AuthProvider.clearError', () {
    test('deve limpar a mensagem de erro', () async {
      when(mockAuthService.login(any, any)).thenThrow(Exception('Erro'));
      await provider.login('email', 'senha');
      expect(provider.error, isNotNull);

      provider.clearError();

      expect(provider.error, isNull);
    });

    test('não deve notificar quando não havia erro', () {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.clearError();

      expect(notifyCount, 0);
    });
  });
}
