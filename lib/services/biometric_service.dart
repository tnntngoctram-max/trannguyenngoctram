import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

/// Xác thực Vân tay / Face ID / PIN thiết bị
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isSupported() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      if (!canAuthenticate) return false;

      // Kiểm tra thiết bị có thực sự đã đăng ký vân tay/khuôn mặt/PIN chưa
      final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      debugPrint('Biometric isSupported error: $e');
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Xác thực vân tay / mã PIN thiết bị để điểm danh',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Cho phép dùng PIN/Mẫu hình nếu không quét được vân tay
        ),
      );
    } catch (e) {
      debugPrint('Biometric authenticate error: $e');
      return false;
    }
  }
}
