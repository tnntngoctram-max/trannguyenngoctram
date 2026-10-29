/// URL Backend API & App Constants
class ConfigUrl {
  static const String baseUrl = 'http://api3conca.somee.com/api';
  
  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String verifyEmail = '$baseUrl/auth/verify-email';
  static const String verifyLoginOtp = '$baseUrl/auth/verify-login-otp';
  static const String refreshToken = '$baseUrl/auth/refresh-token';
  static const String logout = '$baseUrl/auth/logout';
  static const String me = '$baseUrl/auth/me';

  // Attendance & Sessions endpoints
  static const String scanQr = '$baseUrl/attendance/scan-qr';
  static const String myHistory = '$baseUrl/attendance/my-history';
  static const String mySummary = '$baseUrl/attendance/my-summary';
  
  static const String attendanceSessions = '$baseUrl/attendance-sessions';
  static const String classSessions = '$baseUrl/class-sessions';
  static const String studentSchedule = '$baseUrl/students/me/schedule';
  static const String teacherSchedule = '$baseUrl/teachers/me/schedule';
}
