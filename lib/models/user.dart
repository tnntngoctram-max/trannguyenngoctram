/// Model Người dùng (Sinh viên/Giảng viên/Admin)
class User {
  final String id;
  final String name;
  final String email;
  final String role; // student, staff, admin

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String roleStr = 'student';
    if (json['roles'] is List && (json['roles'] as List).isNotEmpty) {
      roleStr = json['roles'][0].toString();
    } else if (json['role'] != null) {
      roleStr = json['role'].toString();
    }
    return User(
      id: json['id']?.toString() ?? '',
      name: json['fullName']?.toString() ?? json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: roleStr,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}
