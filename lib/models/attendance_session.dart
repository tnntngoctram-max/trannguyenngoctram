/// Model Phiên điểm danh
class AttendanceSession {
  final String id;
  final String className;
  final String subjectCode;
  final DateTime startTime;
  final DateTime endTime;
  final String qrCodeData;
  final double latitude;
  final double longitude;
  final double radiusMeters;

  AttendanceSession({
    required this.id,
    required this.className,
    required this.subjectCode,
    required this.startTime,
    required this.endTime,
    required this.qrCodeData,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    return AttendanceSession(
      id: json['id'] ?? '',
      className: json['class_name'] ?? '',
      subjectCode: json['subject_code'] ?? '',
      startTime: DateTime.parse(json['start_time'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(json['end_time'] ?? DateTime.now().toIso8601String()),
      qrCodeData: json['qr_code_data'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      radiusMeters: (json['radius_meters'] ?? 50.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_name': className,
      'subject_code': subjectCode,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'qr_code_data': qrCodeData,
      'latitude': latitude,
      'longitude': longitude,
      'radius_meters': radiusMeters,
    };
  }
}
