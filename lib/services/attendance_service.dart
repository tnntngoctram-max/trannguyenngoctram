import 'api_client.dart';
import '../config/config_url.dart';
import '../models/attendance_session.dart';
import '../models/attendance_record.dart';
import 'dart:convert';

/// Kết quả trả veề từ API Quét QR điểm danh
class ScanQrResponse {
  final bool isSuccess;
  final String message;
  final int statusCode;

  ScanQrResponse({
    required this.isSuccess,
    required this.message,
    required this.statusCode,
  });
}

/// API Điểm danh (Aligned with api_n3conca)
class AttendanceService {
  final ApiClient _apiClient = ApiClient();

  Future<ScanQrResponse> scanQr({
    required String qrCode,
  }) async {
    try {
      String cleanCode = qrCode.trim();
      // Trích xuất mã nếu QR dạng JSON string
      if (cleanCode.startsWith('{') && cleanCode.endsWith('}')) {
        try {
          final Map<String, dynamic> parsed = jsonDecode(cleanCode);
          cleanCode = parsed['qrCode'] ?? parsed['qrToken'] ?? parsed['code'] ?? parsed['token'] ?? cleanCode;
        } catch (_) {}
      }

      final response = await _apiClient.post(ConfigUrl.scanQr, {
        'qrCode': cleanCode,
        'code': cleanCode,
        'token': cleanCode,
        'qrToken': cleanCode,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        String msg = 'Điểm danh thành công!';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded.containsKey('message')) {
            msg = decoded['message'];
          }
        } catch (_) {}
        return ScanQrResponse(isSuccess: true, message: msg, statusCode: response.statusCode);
      } else {
        String errorMsg = 'Mã QR không hợp lệ hoặc đã hết hạn!';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map) {
            errorMsg = decoded['message'] ?? decoded['error'] ?? decoded['title'] ?? errorMsg;
          } else if (decoded is String && decoded.isNotEmpty) {
            errorMsg = decoded;
          }
        } catch (_) {
          if (response.body.isNotEmpty && response.body.length < 150) {
            errorMsg = response.body;
          }
        }
        return ScanQrResponse(
          isSuccess: false,
          message: '$errorMsg (Mã lỗi HTTP ${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ScanQrResponse(
        isSuccess: false,
        message: 'Lỗi kết nối máy chủ: $e',
        statusCode: 500,
      );
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
