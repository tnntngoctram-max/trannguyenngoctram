import 'api_client.dart';
import '../config/config_url.dart';
import 'dart:convert';

/// Service quản lý Môn học & Lịch học
class CourseService {
  final ApiClient _apiClient = ApiClient();

  Future<List<dynamic>> getCourses() async {
    try {
      final response = await _apiClient.get(ConfigUrl.courses);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> getMyCourses() async {
    try {
      final response = await _apiClient.get(ConfigUrl.myCourses);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> getClassSessions() async {
    try {
      final response = await _apiClient.get(ConfigUrl.classSessions);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<bool> createCourse(Map<String, dynamic> courseData) async {
    try {
      final response = await _apiClient.post(ConfigUrl.courses, courseData);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> enrollCourse(int courseId) async {
    try {
      final response = await _apiClient.post('${ConfigUrl.courses}/$courseId/enroll', {});
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<List<dynamic>> getStudentSchedule() async {
    try {
      final response = await _apiClient.get(ConfigUrl.studentSchedule);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> getTeacherSchedule() async {
    try {
      final response = await _apiClient.get(ConfigUrl.teacherSchedule);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
