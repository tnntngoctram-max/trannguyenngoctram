/// Model Lịch sử điểm danh (Aligned with api_n3conca)
class AttendanceRecord {
  final int id;
  final int attendanceSessionId;
  final String courseCode;
  final String courseName;
  final DateTime attendanceTime;
  final String status;

  AttendanceRecord({
    required this.id,
    required this.attendanceSessionId,
    required this.courseCode,
    required this.courseName,
    required this.attendanceTime,
    required this.status,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] ?? 0,
      attendanceSessionId: json['attendanceSessionId'] ?? 0,
      courseCode: json['courseCode'] ?? '',
      courseName: json['courseName'] ?? '',
      attendanceTime: DateTime.parse(json['markedAt'] ?? json['attendanceTime'] ?? DateTime.now().toIso8601String()),
      status: json['status']?.toString() ?? 'Present',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attendanceSessionId': attendanceSessionId,
      'courseCode': courseCode,
      'courseName': courseName,
      'markedAt': attendanceTime.toIso8601String(),
      'status': status,
    };
  }
}
