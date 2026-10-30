import 'package:flutter/material.dart';
import '../../services/attendance_service.dart';
import '../../services/biometric_service.dart';

/// Màn hình Quét mã QR điểm danh (Aligned with api_n3conca)
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  final BiometricService _biometricService = BiometricService();
  bool _isProcessing = false;
  String _statusMessage = 'Đang chờ quét mã QR...';

  void _simulateScanAndCheckIn(String qrCode) async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Đang xác thực sinh trắc học...';
    });

    // 1. Check Biometric
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

    // 2. Send Check-In API (Aligned with api_n3conca ScanQrRequest expecting qrCode)
    setState(() => _statusMessage = 'Đang gửi thông tin điểm danh lên hệ thống...');
    bool success = await _attendanceService.scanQr(qrCode: qrCode);

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
                onPressed: () => _simulateScanAndCheckIn('SAMPLE_QR_CODE_XYZ123'),
              ),
          ],
        ),
      ),
    );
  }
}
