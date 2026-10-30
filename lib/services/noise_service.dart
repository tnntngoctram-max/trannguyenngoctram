import 'api_client.dart';
import '../config/config_url.dart';
import 'dart:convert';

/// Service quản lý Đo tiếng ồn lớp học
class NoiseService {
  final ApiClient _apiClient = ApiClient();

  Future<bool> recordNoise({required int classSessionId, required double decibel}) async {
    try {
      final response = await _apiClient.post(ConfigUrl.noiseMeasurements, {
        'classSessionId': classSessionId,
        'decibel': decibel,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<List<dynamic>> getSessionNoise(int sessionId) async {
    try {
      final response = await _apiClient.get('${ConfigUrl.noiseMeasurements}/session/$sessionId');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
