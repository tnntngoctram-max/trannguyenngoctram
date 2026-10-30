import 'dart:convert';

/// Giải mã JWT Token (lấy Role, UserId)
class AuthUtils {
  static Map<String, dynamic>? decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }
      final payload = _decodeBase64(parts[1]);
      final payloadMap = jsonDecode(payload);
      if (payloadMap is Map<String, dynamic>) {
        return payloadMap;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!');
    }
    return utf8.decode(base64Url.decode(output));
  }

  static String? getRole(String token) {
    final decoded = decodeJwt(token);
    return decoded?['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ?? decoded?['role'];
  }

  static String? getUserId(String token) {
    final decoded = decodeJwt(token);
    return decoded?['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ?? decoded?['user_id'] ?? decoded?['sub'];
  }
}
