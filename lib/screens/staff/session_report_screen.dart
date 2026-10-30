import 'package:flutter/material.dart';
import '../../services/attendance_service.dart';
import '../../models/attendance_session.dart';
import '../../utils/constants.dart';
import 'session_detail_screen.dart';

/// Xem danh sách & Báo cáo điểm danh (Soft rounded icons & session management)
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.defaultRadius)),
                child: ListTile(
                  leading: const Icon(Icons.event_note_rounded, color: AppConstants.primaryColor, size: 28),
                  title: Text('Phiên #${session.id} (Lớp #${session.classSessionId})', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Trạng thái: ${session.isOpen ? "Đang mở" : "Đã đóng"}'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SessionDetailScreen(
                          sessionId: session.id,
                          classSessionId: session.classSessionId,
                          isOpenInitial: session.isOpen,
                          qrCodeInitial: session.qrCode,
                        ),
                      ),
                    );
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
