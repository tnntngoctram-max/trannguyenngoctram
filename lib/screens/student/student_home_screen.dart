import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'qr_scanner_screen.dart';
import 'student_schedule_screen.dart';
import 'location_share_screen.dart';

/// Trang chủ Sinh viên (Giao diện tinh gọn, không trùng lặp với Navbar)
class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ Sinh viên'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppConstants.cardColor,
                  borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.school_rounded, color: AppConstants.primaryColor, size: 32),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Xin chào Sinh viên!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textColor)),
                          SizedBox(height: 4),
                          Text('Sẵn sàng điểm danh và xem lịch học.', style: TextStyle(fontSize: 13, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(18)),
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 26),
                label: const Text('Quét mã QR điểm danh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QrScannerScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(18),
                  side: const BorderSide(color: AppConstants.primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.defaultRadius)),
                ),
                icon: const Icon(Icons.event_rounded, size: 26, color: AppConstants.primaryColor),
                label: const Text('Thời khóa biểu cá nhân', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.primaryColor)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StudentScheduleScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(18),
                  side: const BorderSide(color: AppConstants.primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.defaultRadius)),
                ),
                icon: const Icon(Icons.location_on_rounded, size: 26, color: AppConstants.primaryColor),
                label: const Text('Chia sẻ vị trí GPS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.primaryColor)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LocationShareScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
