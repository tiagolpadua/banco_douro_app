import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../exceptions/api_exceptions.dart';

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
      final errorBody = response.body;
      if (errorBody.contains('Cannot find user')) {
        throw UserNotFoundException();
      }
      throw HttpException(errorBody);
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

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }
}
