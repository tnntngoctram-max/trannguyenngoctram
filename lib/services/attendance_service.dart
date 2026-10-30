import 'api_client.dart';
import '../config/config_url.dart';
import '../models/attendance_session.dart';
import '../models/attendance_record.dart';
import 'dart:convert';

/// API Điểm danh (Aligned with api_n3conca)
class AttendanceService {
  final ApiClient _apiClient = ApiClient();

  Future<bool> scanQr({
    required String qrCode,
  }) async {
    try {
      final response = await _apiClient.post(ConfigUrl.scanQr, {
        'qrCode': qrCode,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<List<AttendanceRecord>> getMyHistory() async {
    try {
      final response = await _apiClient.get(ConfigUrl.myHistory);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = decoded is List ? decoded : (decoded['items'] ?? []);
        return data.map((e) => AttendanceRecord.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<AttendanceSession>> getAttendanceSessions() async {
    try {
      final response = await _apiClient.get(ConfigUrl.attendanceSessions);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = decoded is List ? decoded : (decoded['items'] ?? []);
        return data.map((e) => AttendanceSession.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> createAttendanceSession(int classSessionId) async {
    try {
      final response = await _apiClient.post(ConfigUrl.attendanceSessions, {
        'classSessionId': classSessionId,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> refreshQr(int sessionId) async {
    try {
      final response = await _apiClient.post('${ConfigUrl.attendanceSessions}/$sessionId/refresh-qr', {});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> closeSession(int sessionId) async {
    try {
      final response = await _apiClient.post('${ConfigUrl.attendanceSessions}/$sessionId/close', {});
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<dynamic>> getSessionDetails(int sessionId) async {
    try {
      final response = await _apiClient.get('${ConfigUrl.baseUrl}/attendance/session/$sessionId');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded is List ? decoded : [decoded];
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
