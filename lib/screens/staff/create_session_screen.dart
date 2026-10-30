import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/attendance_service.dart';
import '../../services/course_service.dart';

/// Tạo phiên điểm danh & hiển thị QR Động thực tế với đồng hồ đếm ngược
class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  final CourseService _courseService = CourseService();
  
  bool _isLoading = false;
  bool _isLoadingSessions = true;
  List<dynamic> _classSessions = [];
  int? _selectedClassSessionId;
  Map<String, dynamic>? _sessionData;
  
  Timer? _timer;
  int _remainingSeconds = 120; // 2 minutes QR lifetime

  @override
  void initState() {
    super.initState();
    _loadClassSessions();
  }

  @override
  void dispose() {
    _timer?.cancel();
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

  void _createSession() async {
    if (_selectedClassSessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn buổi học!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await _attendanceService.createAttendanceSession(_selectedClassSessionId!);
    setState(() {
      _isLoading = false;
      _sessionData = result;
      _remainingSeconds = 120; // reset to 2 minutes
    });

    if (result != null && mounted) {
      _startCountdown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tạo phiên điểm danh thành công!')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tạo phiên điểm danh thất bại!')),
      );
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _formatTimer(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo phiên điểm danh')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Chọn buổi học cần điểm danh:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _isLoadingSessions
                  ? const Center(child: CircularProgressIndicator())
                  : _classSessions.isEmpty
                      ? const Text('Không có buổi học nào trong hệ thống.')
                      : InputDecorator(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Buổi học',
                            prefixIcon: Icon(Icons.class_),
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
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: (_isLoading || _isLoadingSessions || _classSessions.isEmpty) ? null : _createSession,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Tạo Phiên & Hiển thị QR', style: TextStyle(fontSize: 16)),
                ),
              ),
              if (_sessionData != null) ...[
                const SizedBox(height: 32),
                const Text('Mã QR Động cho phiên điểm danh:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.indigo, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: QrImageView(
                          data: _sessionData!['qrCode'] ?? '',
                          version: QrVersions.auto,
                          size: 200.0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SelectableText(
                        'Token: ${_sessionData!['qrCode'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _remainingSeconds > 0
                            ? 'Mã QR hết hạn sau: ${_formatTimer(_remainingSeconds)}'
                            : 'Mã QR đã hết hạn! Vui lòng làm mới.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _remainingSeconds > 0 ? Colors.redAccent : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Sinh viên có thể quét mã QR này để điểm danh.', textAlign: TextAlign.center),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
