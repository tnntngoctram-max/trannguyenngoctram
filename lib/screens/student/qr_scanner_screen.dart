import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/attendance_service.dart';
import '../../services/biometric_service.dart';
import '../../utils/constants.dart';

/// Màn hình Quét mã QR Điểm danh thực tế bằng Camera (MobileScanner)
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  final BiometricService _biometricService = BiometricService();

  late MobileScannerController _scannerController;
  bool _isCameraPermissionGranted = false;
  bool _isCheckingPermission = true;
  bool _isProcessing = false;
  String _statusMessage = 'Đưa camera vào vùng mã QR để quét';
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    _checkCameraPermission();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  /// Kiểm tra và xin quyền Camera
  Future<void> _checkCameraPermission() async {
    setState(() => _isCheckingPermission = true);
    var status = await Permission.camera.status;

    if (status.isGranted) {
      setState(() {
        _isCameraPermissionGranted = true;
        _isCheckingPermission = false;
      });
      return;
    }

    if (status.isPermanentlyDenied) {
      setState(() {
        _isCameraPermissionGranted = false;
        _isCheckingPermission = false;
      });
      if (mounted) {
        _showSettingsDialog();
      }
      return;
    }

    // Chưa được cấp quyền -> Bật pop-up hỏi người dùng
    if (mounted) {
      final confirm = await _showPermissionRequestDialog();
      if (confirm) {
        status = await Permission.camera.request();
        if (status.isGranted) {
          setState(() {
            _isCameraPermissionGranted = true;
            _isCheckingPermission = false;
          });
        } else if (status.isPermanentlyDenied) {
          setState(() {
            _isCameraPermissionGranted = false;
            _isCheckingPermission = false;
          });
          if (mounted) _showSettingsDialog();
        } else {
          setState(() {
            _isCameraPermissionGranted = false;
            _isCheckingPermission = false;
          });
        }
      } else {
        setState(() {
          _isCameraPermissionGranted = false;
          _isCheckingPermission = false;
        });
      }
    }
  }

  /// Dialog yêu cầu cấp quyền Camera
  Future<bool> _showPermissionRequestDialog() async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.camera_alt_rounded, color: AppConstants.primaryColor, size: 28),
            SizedBox(width: 8),
            Text('Quyền Camera'),
          ],
        ),
        content: const Text(
          'Ứng dụng cần quyền sử dụng Camera để quét mã QR điểm danh cho sinh viên.\n\n'
          'Vui lòng đồng ý cấp quyền để tiếp tục.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cấp quyền', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Dialog dẫn tới cài đặt nếu quyền bị từ chối vĩnh viễn
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.no_photography_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Chưa có quyền Camera'),
          ],
        ),
        content: const Text(
          'Quyền Camera đã bị từ chối. Vui lòng truy cập Cài đặt ứng dụng để bật lại quyền Camera cho ứng dụng.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor),
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Mở cài đặt', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Dialog khi xác thực sinh trắc học không thành công / bị hủy
  Future<bool> _showBiometricFailedDialog() async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.fingerprint_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Xác thực sinh trắc học'),
          ],
        ),
        content: const Text(
          'Không thể hoàn tất xác thực sinh trắc học trên thiết bị.\n\n'
          'Bạn có muốn bỏ qua bước sinh trắc học và tiếp tục gửi điểm danh theo mã QR không?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Bỏ qua & Điểm danh', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Xử lý mã QR sau khi quét thành công
  void _onQrCodeScanned(String qrCode) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Đang xử lý mã QR...';
    });

    HapticFeedback.mediumImpact();
    await _scannerController.stop();

    // 1. Xác thực sinh trắc học (nếu thiết bị hỗ trợ & có đăng ký)
    bool canAuth = await _biometricService.isSupported();
    if (canAuth) {
      setState(() => _statusMessage = 'Vui lòng xác thực sinh trắc học / mã PIN...');
      bool isAuthenticated = await _biometricService.authenticate();
      
      if (!isAuthenticated && mounted) {
        // Hỏi sinh viên có muốn bỏ qua sinh trắc học để tiếp tục điểm danh bằng QR không
        final bool shouldProceed = await _showBiometricFailedDialog();
        if (!shouldProceed) {
          setState(() {
            _isProcessing = false;
            _statusMessage = 'Đã hủy điểm danh.';
          });
          _scannerController.start();
          return;
        }
      }
    }

    // 2. Gửi API điểm danh lên hệ thống
    setState(() => _statusMessage = 'Đang gửi dữ liệu điểm danh...');
    final ScanQrResponse response = await _attendanceService.scanQr(qrCode: qrCode);

    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _statusMessage = response.isSuccess ? 'Điểm danh thành công!' : 'Điểm danh thất bại!';
    });

    if (response.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      _showErrorDialog(response.message);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Lỗi điểm danh'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _scannerController.start();
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét mã QR Điểm danh'),
        actions: [
          if (_isCameraPermissionGranted) ...[
            IconButton(
              icon: Icon(_isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded),
              onPressed: () async {
                await _scannerController.toggleTorch();
                setState(() => _isTorchOn = !_isTorchOn);
              },
            ),
            IconButton(
              icon: const Icon(Icons.cameraswitch_rounded),
              onPressed: () => _scannerController.switchCamera(),
            ),
          ],
        ],
      ),
      body: _isCheckingPermission
          ? const Center(child: CircularProgressIndicator())
          : !_isCameraPermissionGranted
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt_outlined, size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Cần quyền Camera để quét mã QR điểm danh!',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          ),
                          icon: const Icon(Icons.security_rounded, color: Colors.white),
                          label: const Text('Cấp quyền Camera', style: TextStyle(color: Colors.white, fontSize: 16)),
                          onPressed: _checkCameraPermission,
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          MobileScanner(
                            controller: _scannerController,
                            onDetect: (BarcodeCapture capture) {
                              final List<Barcode> barcodes = capture.barcodes;
                              for (final barcode in barcodes) {
                                final String? code = barcode.rawValue;
                                if (code != null && code.isNotEmpty) {
                                  _onQrCodeScanned(code);
                                  break;
                                }
                              }
                            },
                          ),
                          // Khung viền quét QR
                          Container(
                            width: 260,
                            height: 260,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppConstants.primaryColor, width: 4),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          if (_isProcessing)
                            Container(
                              color: Colors.black54,
                              child: const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.black87,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _statusMessage,
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                            ),
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            label: const Text('Thử với mã mẫu (Mô phỏng)'),
                            onPressed: () => _onQrCodeScanned('SAMPLE_QR_CODE_XYZ123'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
