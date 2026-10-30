import 'dart:async';
import 'package:flutter/material.dart';
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

  Future<void> _startRecording() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cần cấp quyền Microphone để đo tiếng ồn!')),
        );
      }
      return;
    }

    try {
      _noiseMeter = NoiseMeter();
      _noiseSubscription = _noiseMeter?.noise.listen(
        (NoiseReading noiseReading) {
          setState(() {
            _currentDecibel = noiseReading.meanDecibel;
          });
        },
        onError: (Object error) {
          debugPrint('$error');
          _stopRecording();
        },
      );
      setState(() => _isRecording = true);
    } catch (err) {
      debugPrint('$err');
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
        const SnackBar(content: Text('Đã lưu chỉ số tiếng ồn lên hệ thống!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lưu chỉ số tiếng ồn thất bại!')),
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
    return 'Ồn ào (Cần giữ trật tự)';
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
                                child: Text('$code - $name ($room)'),
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
                        ? const CircularProgressIndicator(color: Colors.white)
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
