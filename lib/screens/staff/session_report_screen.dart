import 'package:flutter/material.dart';
import '../../services/attendance_service.dart';
import '../../models/attendance_session.dart';

/// Xem danh sách & Báo cáo điểm danh
class SessionReportScreen extends StatefulWidget {
  const SessionReportScreen({super.key});

  @override
  State<SessionReportScreen> createState() => _SessionReportScreenState();
}

class _SessionReportScreenState extends State<SessionReportScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  late Future<List<AttendanceSession>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = _attendanceService.getAttendanceSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Báo cáo điểm danh')),
      body: FutureBuilder<List<AttendanceSession>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có phiên điểm danh nào.'));
          }

          final sessions = snapshot.data!;
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(session.className, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Môn: ${session.subjectCode}\nBắt đầu: ${session.startTime}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to detail report if needed
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
