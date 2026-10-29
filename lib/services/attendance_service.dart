import 'api_client.dart';
import '../config/config_url.dart';
import '../models/attendance_session.dart';
import '../models/attendance_record.dart';
import 'dart:convert';

/// API Tạo & Gửi điểm danh
class AttendanceService {
  final ApiClient _apiClient = ApiClient();

  Future<bool> scanQr({
    required String qrData,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _apiClient.post(ConfigUrl.scanQr, {
        'qr_data': qrData,
        'latitude': latitude,
        'longitude': longitude,
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
        final List data = jsonDecode(response.body);
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
        final List data = jsonDecode(response.body);
        return data.map((e) => AttendanceSession.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> createAttendanceSession(Map<String, dynamic> sessionData) async {
    try {
      final response = await _apiClient.post(ConfigUrl.attendanceSessions, sessionData);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
