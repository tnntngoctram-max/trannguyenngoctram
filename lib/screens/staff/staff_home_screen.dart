import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'create_session_screen.dart';

/// Trang chủ Giảng viên (Tạo QR trực tiếp ngay trang chủ, gọn gàng không trùng lặp Navbar)
class StaffHomeScreen extends StatelessWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ Giảng viên'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
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
                  Icon(Icons.waving_hand_rounded, color: AppConstants.primaryColor, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Xin chào Giảng viên!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textColor)),
                        SizedBox(height: 4),
                        Text('Tạo mã QR điểm danh nhanh chóng cho lớp học.', style: TextStyle(fontSize: 13, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
              icon: const Icon(Icons.qr_code_2_rounded, size: 32),
              label: const Text('Tạo phiên điểm danh & Hiển thị QR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateSessionScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
