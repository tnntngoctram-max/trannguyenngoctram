import 'api_client.dart';
import '../config/config_url.dart';
import 'dart:convert';

/// Service quản lý Thông báo
class NotificationService {
  final ApiClient _apiClient = ApiClient();

  Future<List<dynamic>> getNotifications() async {
    try {
      final response = await _apiClient.get(ConfigUrl.notifications);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await _apiClient.post('${ConfigUrl.notifications}/$notificationId/read', {});
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiClient.post('${ConfigUrl.notifications}/read-all', {});
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
