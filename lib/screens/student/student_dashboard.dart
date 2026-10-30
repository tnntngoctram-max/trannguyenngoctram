import 'package:flutter/material.dart';
import 'student_home_screen.dart';
import 'student_courses_screen.dart';
import 'attendance_history_screen.dart';
import '../settings/settings_screen.dart';

/// Bottom Navigation Bar Dashboard cho Sinh viên
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const StudentHomeScreen(),
    const StudentCoursesScreen(),
    const AttendanceHistoryScreen(),
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
          BottomNavigationBarItem(icon: Icon(Icons.book_rounded), label: 'Môn học'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Điểm danh'),
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
