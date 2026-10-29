import 'package:flutter/material.dart';
import '../../services/attendance_service.dart';

/// Tạo phiên điểm danh & hiển thị QR Động
class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _classNameController = TextEditingController();
  final _subjectCodeController = TextEditingController();
  final AttendanceService _attendanceService = AttendanceService();
  bool _isLoading = false;
  bool _created = false;

  void _createSession() async {
    setState(() => _isLoading = true);
    bool success = await _attendanceService.createAttendanceSession({
      'class_name': _classNameController.text.trim(),
      'subject_code': _subjectCodeController.text.trim(),
      'start_time': DateTime.now().toIso8601String(),
      'end_time': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
      'latitude': 10.762622,
      'longitude': 106.660172,
      'radius_meters': 50.0,
    });
    setState(() {
      _isLoading = false;
      _created = success;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tạo phiên điểm danh thành công!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo phiên điểm danh')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _classNameController,
                decoration: const InputDecoration(labelText: 'Tên lớp học', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _subjectCodeController,
                decoration: const InputDecoration(labelText: 'Mã môn học', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createSession,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Tạo Phiên & Hiển thị QR', style: TextStyle(fontSize: 16)),
                ),
              ),
              if (_created) ...[
                const SizedBox(height: 32),
                const Text('Mã QR Động cho phiên:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Icon(Icons.qr_code, size: 150, color: Colors.indigo),
                const SizedBox(height: 8),
                const Text('Sinh viên có thể quét mã này trong bán kính cho phép.'),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
