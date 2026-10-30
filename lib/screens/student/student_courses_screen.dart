import 'package:flutter/material.dart';
import '../../services/course_service.dart';
import '../../utils/constants.dart';

/// Quản lý Môn học & Đăng ký môn học của sinh viên
class StudentCoursesScreen extends StatefulWidget {
  const StudentCoursesScreen({super.key});

  @override
  State<StudentCoursesScreen> createState() => _StudentCoursesScreenState();
}

class _StudentCoursesScreenState extends State<StudentCoursesScreen> {
  final CourseService _courseService = CourseService();
  late Future<List<dynamic>> _coursesFuture;
  late Future<List<dynamic>> _myCoursesFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _coursesFuture = _courseService.getCourses();
    _myCoursesFuture = _courseService.getMyCourses();
  }

  void _enroll(int courseId) async {
    final success = await _courseService.enrollCourse(courseId);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký môn học thành công!')),
      );
      setState(() {
        _loadData();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thất bại hoặc đã đăng ký môn này.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý Môn học'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Đã đăng ký'),
              Tab(text: 'Tất cả môn học'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // My Courses
            FutureBuilder<List<dynamic>>(
              future: _myCoursesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Bạn chưa đăng ký môn học nào.'));
                }
                final list = snapshot.data!;
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final c = list[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.defaultRadius)),
                      child: ListTile(
                        leading: const Icon(Icons.book_rounded, color: AppConstants.secondaryColor, size: 32),
                        title: Text('${c['code']} - ${c['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Tín chỉ: ${c['credits'] ?? 3} | GV: ${c['teacher'] ?? 'Chưa phân công'}'),
                      ),
                    );
                  },
                );
              },
            ),
            // All Courses
            FutureBuilder<List<dynamic>>(
              future: _coursesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có môn học nào.'));
                }
                final list = snapshot.data!;
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final c = list[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.defaultRadius)),
                      child: ListTile(
                        leading: const Icon(Icons.menu_book_rounded, color: AppConstants.primaryColor, size: 32),
                        title: Text('${c['code']} - ${c['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Tín chỉ: ${c['credits'] ?? 3} | SV: ${c['studentCount'] ?? 0}'),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor),
                          onPressed: () => _enroll(c['id']),
                          child: const Text('Đăng ký'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
