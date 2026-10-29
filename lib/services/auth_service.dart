import 'api_client.dart';
import '../config/config_url.dart';
import '../utils/storage.dart';
import '../models/user.dart';
import 'dart:convert';

/// API Đăng nhập, Đăng ký, OTP, Refresh Token
class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.post(ConfigUrl.login, {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] ?? data['accessToken'];
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

  Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
    try {
      final response = await _apiClient.post(ConfigUrl.register, {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': response.body};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<bool> verifyEmail(String email, String code) async {
    try {
      final response = await _apiClient.post(ConfigUrl.verifyEmail, {
        'email': email,
        'code': code,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyLoginOtp(String email, String otp) async {
    try {
      final response = await _apiClient.post(ConfigUrl.verifyLoginOtp, {
        'email': email,
        'otp': otp,
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] ?? data['accessToken'];
        if (token != null) {
          await Storage.saveToken(token);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
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
    try {
      await _apiClient.post(ConfigUrl.logout, {});
    } catch (_) {}
    await Storage.clearToken();
  }
}
