import 'package:flutter/material.dart';
import 'staff_home_screen.dart';
import 'noise_measurement_screen.dart';
import '../settings/settings_screen.dart';

/// Bottom Navigation Bar Dashboard cho Giảng viên (Đã lược bỏ tab báo cáo)
class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const StaffHomeScreen(),
    const NoiseMeasurementScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.mic_rounded), label: 'Tiếng ồn'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Cài đặt'),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
