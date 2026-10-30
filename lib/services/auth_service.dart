import 'api_client.dart';
import '../config/config_url.dart';
import '../utils/storage.dart';
import '../models/user.dart';
import 'dart:convert';

/// API Đăng nhập, Đăng ký (Aligned with api_n3conca)
class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> login(String emailOrUsername, String password) async {
    try {
      final response = await _apiClient.post(ConfigUrl.login, {
        'emailOrUsername': emailOrUsername,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['accessToken'];
        if (token != null) {
          await Storage.saveToken(token);
          return {'success': true, 'data': data};
        }
      }
      return {'success': false, 'message': response.body};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> register(String fullName, String email, String username, String password) async {
    try {
      final response = await _apiClient.post(ConfigUrl.register, {
        'fullName': fullName,
        'email': email,
        'username': username,
        'password': password,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': response.body};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ConfigUrl.me);
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await Storage.clearToken();
  }
}
