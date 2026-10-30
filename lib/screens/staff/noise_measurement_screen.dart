import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/noise_service.dart';
import '../../services/course_service.dart';
import '../../utils/constants.dart';

/// Màn hình Đo tiếng ồn lớp học theo thời gian thực (Noise Measurement)
class NoiseMeasurementScreen extends StatefulWidget {
  const NoiseMeasurementScreen({super.key});

  @override
  State<NoiseMeasurementScreen> createState() => _NoiseMeasurementScreenState();
}

class _NoiseMeasurementScreenState extends State<NoiseMeasurementScreen> {
  final NoiseService _noiseService = NoiseService();
  final CourseService _courseService = CourseService();

  bool _isRecording = false;
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  double _currentDecibel = 0.0;

  bool _isLoadingSessions = true;
  List<dynamic> _classSessions = [];
  int? _selectedClassSessionId;
  bool _isSaving = false;

  // Cấu hình cảnh báo quá ồn
  static const double _highNoiseThreshold = 75.0; // Ngưỡng ồn ào (dB)
  DateTime? _lastAlertTime; // Giới hạn tần suất bật dialog cảnh báo
  bool _isShowingNoiseDialog = false;

  @override
  void initState() {
    super.initState();
    _loadClassSessions();
  }

  @override
  void dispose() {
    _stopRecording();
    super.dispose();
  }

  void _loadClassSessions() async {
    final sessions = await _courseService.getClassSessions();
    setState(() {
      _classSessions = sessions;
      _isLoadingSessions = false;
      if (sessions.isNotEmpty) {
        _selectedClassSessionId = sessions[0]['id'];
      }
    });
  }

  /// Hiển thị Pop-up Dialog xin quyền Microphone từ giáo viên
  Future<bool> _showRequestPermissionDialog() async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.mic_rounded, color: AppConstants.primaryColor, size: 28),
            SizedBox(width: 8),
            Text('Quyền Microphone'),
          ],
        ),
        content: const Text(
          'Ứng dụng cần cấp quyền sử dụng Microphone để đo cường độ tiếng ồn lớp học của giáo viên.\n\n'
          'Bạn có đồng ý bật pop-up cấp quyền Microphone không?',
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
            child: const Text('Cho phép', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Yêu cầu cấp quyền Microphone kèm thông báo chi tiết
  Future<void> _startRecording() async {
    // 1. Kiểm tra trạng thái quyền
    var status = await Permission.microphone.status;

    // 2. Nếu bị từ chối vĩnh viễn -> Bật dialog mở Cài đặt
    if (status.isPermanentlyDenied) {
      if (mounted) {
        _showPermissionDialog();
      }
      return;
    }

    // 3. Nếu chưa được cấp quyền -> Bật pop-up giải thích và xin cấp quyền
    if (!status.isGranted) {
      if (mounted) {
        final confirm = await _showRequestPermissionDialog();
        if (!confirm) return;
      }

      // Bật pop-up xin quyền của hệ thống Android
      status = await Permission.microphone.request();

      if (status.isPermanentlyDenied) {
        if (mounted) {
          _showPermissionDialog();
        }
        return;
      }

      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cần cấp quyền Microphone để sử dụng tính năng đo tiếng ồn!'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }
    }

    // 4. Đã cấp quyền thành công -> Tiến hành đo
    try {
      _noiseMeter = NoiseMeter();
      _noiseSubscription = _noiseMeter?.noise.listen(
        (NoiseReading noiseReading) {
          if (!mounted) return;
          final db = noiseReading.meanDecibel;
          setState(() {
            _currentDecibel = db;
          });

          _checkAndNotifyHighNoise(db);
        },
        onError: (Object error) {
          debugPrint('NoiseMeter Error: $error');
          _stopRecording();
        },
      );
      setState(() => _isRecording = true);
    } catch (err) {
      debugPrint('Error starting noise meter: $err');
    }
  }

  /// Hiển thị Dialog yêu cầu mở Cài đặt nếu quyền Mic bị từ chối vĩnh viễn
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.mic_off_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Quyền Microphone'),
          ],
        ),
        content: const Text(
          'Ứng dụng cần quyền sử dụng Microphone để đo cường độ tiếng ồn lớp học. '
              'Vui lòng vào phần Cài đặt ứng dụng để bật lại quyền này.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Mở cài đặt'),
          ),
        ],
      ),
    );
  }

  /// Kiểm tra và cảnh báo khi mức độ ồn vượt ngưỡng (75 dB)
  void _checkAndNotifyHighNoise(double db) {
    if (db >= _highNoiseThreshold && !_isShowingNoiseDialog) {
      final now = DateTime.now();
      // Chỉ bật cảnh báo mỗi 10 giây một lần để tránh làm phiền
      if (_lastAlertTime == null || now.difference(_lastAlertTime!).inSeconds >= 10) {
        _lastAlertTime = now;
        _isShowingNoiseDialog = true;

        // Phát hiệu ứng rung thông báo
        HapticFeedback.vibrate();

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.red.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                SizedBox(width: 8),
                Text('CẢNH BÁO TIẾNG ỒN', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              'Cường độ âm thanh lớp học hiện tại đạt ${db.toStringAsFixed(1)} dB (vượt ngưỡng cho phép).\n\n'
                  'Vui lòng nhắc nhở sinh viên giữ trật tự để đảm bảo chất lượng buổi học!',
              style: const TextStyle(fontSize: 15),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  _isShowingNoiseDialog = false;
                  Navigator.pop(context);
                },
                child: const Text('Đã hiểu', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ).then((_) => _isShowingNoiseDialog = false);
      }
    }
  }

  void _stopRecording() {
    _noiseSubscription?.cancel();
    _noiseSubscription = null;
    setState(() => _isRecording = false);
  }

  void _saveNoiseMeasurement() async {
    if (_selectedClassSessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn buổi học!')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final success = await _noiseService.recordNoise(
      classSessionId: _selectedClassSessionId!,
      decibel: _currentDecibel.isFinite ? _currentDecibel : 0.0,
    );
    setState(() => _isSaving = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu chỉ số tiếng ồn lên hệ thống!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lưu chỉ số tiếng ồn thất bại!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getNoiseColor(double db) {
    if (db < 60) return Colors.green;
    if (db < 75) return Colors.orange;
    return Colors.red;
  }

  String _getNoiseStatus(double db) {
    if (db < 60) return 'Yên tĩnh (Chuẩn lớp học)';
    if (db < 75) return 'Ổn định (Có tiếng trao đổi)';
    return 'Ồn ào (Cần giữ trật tự!)';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đo tiếng ồn lớp học')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Chọn buổi học:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _isLoadingSessions
                ? const Center(child: CircularProgressIndicator())
                : _classSessions.isEmpty
                ? const Text('Không có buổi học nào.')
                : InputDecorator(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Buổi học',
                prefixIcon: Icon(Icons.class_rounded, color: AppConstants.primaryColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedClassSessionId,
                  isExpanded: true,
                  items: _classSessions.map<DropdownMenuItem<int>>((session) {
                    final name = session['courseName'] ?? 'Môn học';
                    final code = session['courseCode'] ?? '';
                    final room = session['room'] ?? 'Phòng học';
                    return DropdownMenuItem<int>(
                      value: session['id'],
                      child: Text('$code - $name ($room)', overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedClassSessionId = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getNoiseColor(_currentDecibel).withAlpha(30),
                        border: Border.all(color: _getNoiseColor(_currentDecibel), width: 6),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isRecording ? '${_currentDecibel.toStringAsFixed(1)} dB' : '-- dB',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: _getNoiseColor(_currentDecibel),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isRecording ? 'Đang đo...' : 'Đã dừng',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isRecording ? _getNoiseStatus(_currentDecibel) : 'Bấm nút bên dưới để bắt đầu đo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getNoiseColor(_currentDecibel),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRecording ? Colors.redAccent : AppConstants.primaryColor,
                      padding: const EdgeInsets.all(16),
                    ),
                    icon: Icon(_isRecording ? Icons.stop_rounded : Icons.mic_rounded),
                    label: Text(_isRecording ? 'Dừng đo' : 'Bắt đầu đo', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: _isRecording ? _stopRecording : _startRecording,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.secondaryColor,
                      padding: const EdgeInsets.all(16),
                    ),
                    icon: const Icon(Icons.cloud_upload_rounded),
                    label: _isSaving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Text('Gửi dữ liệu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: _isSaving ? null : _saveNoiseMeasurement,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}