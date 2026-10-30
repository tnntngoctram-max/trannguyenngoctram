/// URL Backend API & App Constants (Aligned with all backend controllers)
class ConfigUrl {
  static const String baseUrl = 'http://webapibaconca.somee.com/api';
  
  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String refreshToken = '$baseUrl/auth/refresh-token';
  static const String me = '$baseUrl/auth/me';

  // Attendance & Sessions endpoints
  static const String scanQr = '$baseUrl/attendance/scan-qr';
  static const String myHistory = '$baseUrl/students/me/attendance';
  static const String attendanceSessions = '$baseUrl/attendance-sessions';
  static const String classSessions = '$baseUrl/class-sessions';
  
  // Courses endpoints
  static const String courses = '$baseUrl/courses';
  static const String myCourses = '$baseUrl/students/me/courses';

  // Schedule endpoints
  static const String studentSchedule = '$baseUrl/students/me/schedule';
  static const String teacherSchedule = '$baseUrl/teachers/me/schedule';

  // Noise measurements endpoints
  static const String noiseMeasurements = '$baseUrl/noise-measurements';

  // Notifications endpoints
  static const String notifications = '$baseUrl/notifications';

  // Admin endpoints
  static const String adminDashboardStats = '$baseUrl/admin/dashboard-stats';
  static const String adminTeachers = '$baseUrl/admin/teachers';
}
