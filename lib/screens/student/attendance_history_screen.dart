import 'package:flutter/material.dart';
import '../../services/attendance_service.dart';
import '../../models/attendance_record.dart';

/// Lịch sử điểm danh cá nhân
class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  late Future<List<AttendanceRecord>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _attendanceService.getMyHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử điểm danh cá nhân')),
      body: FutureBuilder<List<AttendanceRecord>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Chưa có lịch sử điểm danh nào.'));
          }

          final records = snapshot.data!;
          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text('Phiên: ${record.sessionId}'),
                subtitle: Text('Thời gian: ${record.checkInTime}'),
                trailing: Text(record.status, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
              );
            },
          );
        },
      ),
    );
  }
}
