/// Model Lịch sử điểm danh
class AttendanceRecord {
  final String id;
  final String sessionId;
  final String studentId;
  final String studentName;
  final DateTime checkInTime;
  final String status; // present, absent, late
  final double? latitude;
  final double? longitude;

  AttendanceRecord({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.studentName,
    required this.checkInTime,
    required this.status,
    this.latitude,
    this.longitude,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] ?? '',
      sessionId: json['session_id'] ?? '',
      studentId: json['student_id'] ?? '',
      studentName: json['student_name'] ?? '',
      checkInTime: DateTime.parse(json['check_in_time'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'present',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'student_id': studentId,
      'student_name': studentName,
      'check_in_time': checkInTime.toIso8601String(),
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
