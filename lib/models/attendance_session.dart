/// Model Phiên điểm danh (Aligned with api_n3conca)
class AttendanceSession {
  final int id;
  final int classSessionId;
  final String? qrCode;
  final DateTime? qrExpiresAt;
  final bool isOpen;

  AttendanceSession({
    required this.id,
    required this.classSessionId,
    this.qrCode,
    this.qrExpiresAt,
    required this.isOpen,
  });

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    return AttendanceSession(
      id: json['id'] ?? 0,
      classSessionId: json['classSessionId'] ?? 0,
      qrCode: json['qrCode'],
      qrExpiresAt: json['qrExpiresAt'] != null ? DateTime.parse(json['qrExpiresAt']) : null,
      isOpen: json['isOpen'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classSessionId': classSessionId,
      'qrCode': qrCode,
      'qrExpiresAt': qrExpiresAt?.toIso8601String(),
      'isOpen': isOpen,
    };
  }
}
