import 'package:flutter/material.dart';
import '../../services/attendance_service.dart';
import '../../services/location_service.dart';
import '../../services/biometric_service.dart';

/// Màn hình Quét mã QR điểm danh (tích hợp GPS & Vân tay)
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  final LocationService _locationService = LocationService();
  final BiometricService _biometricService = BiometricService();
  bool _isProcessing = false;
  String _statusMessage = 'Đang chờ quét mã QR...';

  void _simulateScanAndCheckIn(String qrData) async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Đang kiểm tra vị trí GPS...';
    });

    // 1. Check Location
    final position = await _locationService.getCurrentLocation();
    if (position == null) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Không thể lấy vị trí GPS. Vui lòng bật GPS!';
      });
      return;
    }

    // 2. Check Biometric
    setState(() => _statusMessage = 'Đang xác thực sinh trắc học...');
    bool canAuth = await _biometricService.isSupported();
    if (canAuth) {
      bool isAuthenticated = await _biometricService.authenticate();
      if (!isAuthenticated) {
        setState(() {
          _isProcessing = false;
          _statusMessage = 'Xác thực sinh trắc học thất bại!';
        });
        return;
      }
    }

    // 3. Send Check-In API
    setState(() => _statusMessage = 'Đang gửi thông tin điểm danh lên hệ thống...');
    bool success = await _attendanceService.scanQr(
      qrData: qrData,
      latitude: position.latitude,
      longitude: position.longitude,
    );

    setState(() {
      _isProcessing = false;
      _statusMessage = success ? 'Điểm danh thành công!' : 'Điểm danh thất bại!';
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Điểm danh thành công!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quét mã QR Điểm danh')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner, size: 120, color: Colors.indigo),
            const SizedBox(height: 24),
            Text(_statusMessage, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            if (_isProcessing)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Mô phỏng quét QR & Điểm danh'),
                onPressed: () => _simulateScanAndCheckIn('SAMPLE_SESSION_QR_CODE_123'),
              ),
          ],
        ),
      ),
    );
  }
}
