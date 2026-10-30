import 'package:flutter/material.dart';
import '../../services/course_service.dart';
import '../../utils/constants.dart';

/// Thời khóa biểu cá nhân của sinh viên
class StudentScheduleScreen extends StatefulWidget {
  const StudentScheduleScreen({super.key});

  @override
  State<StudentScheduleScreen> createState() => _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends State<StudentScheduleScreen> {
  final CourseService _courseService = CourseService();
  late Future<List<dynamic>> _scheduleFuture;

  @override
  void initState() {
    super.initState();
    _scheduleFuture = _courseService.getStudentSchedule();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thời khóa biểu cá nhân')),
      body: FutureBuilder<List<dynamic>>(
        future: _scheduleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Chưa có lịch học nào.'));
          }

          final schedule = snapshot.data!;
          return ListView.builder(
            itemCount: schedule.length,
            itemBuilder: (context, index) {
              final item = schedule[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.defaultRadius)),
                child: ListTile(
                  leading: const Icon(Icons.event_rounded, color: AppConstants.primaryColor, size: 32),
                  title: Text(item['courseName'] ?? 'Môn học', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Phòng: ${item['room'] ?? 'N/A'}\nBắt đầu: ${item['startsAt'] ?? 'N/A'}'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
