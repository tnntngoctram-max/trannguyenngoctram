import 'api_client.dart';
import '../config/config_url.dart';
import 'dart:convert';

/// Service quản lý Admin
class AdminService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>?> getDashboardStats() async {
    try {
      final response = await _apiClient.get(ConfigUrl.adminDashboardStats);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> createTeacher(Map<String, dynamic> teacherData) async {
    try {
      final response = await _apiClient.post(ConfigUrl.adminTeachers, teacherData);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
