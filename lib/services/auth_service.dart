import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:3000';
  static const String _tokenKey = 'accessToken';

  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/login'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode != 200) {
      throw Exception('Falha no login: ${response.statusCode}');
    }

    return _saveToken(response.body);
  }

  Future<String> _saveToken(String body) async {
    final prefs = await SharedPreferences.getInstance();
    final map = json.decode(body);

    await prefs.setString(_tokenKey, map['accessToken']);
    // await prefs.setString(_userIdKey, map['user']['id'].toString());
    // await prefs.setString(_emailKey, map['user']['email']);

    return map['accessToken'];
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

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<bool> isLoggedIn() async {
    print('>>>> Checking login status...');
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    // await prefs.remove(_userIdKey);
    // await prefs.remove(_emailKey);
  }
}
