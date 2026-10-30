import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../services/course_service.dart';
import '../../utils/constants.dart';

/// Trang quản trị Admin (Thống kê, CRUD Môn học, Thêm Giảng viên)
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final AdminService _adminService = AdminService();
  final CourseService _courseService = CourseService();
  
  late Future<Map<String, dynamic>?> _statsFuture;
  late Future<List<dynamic>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _statsFuture = _adminService.getDashboardStats();
    _coursesFuture = _courseService.getCourses();
  }

  void _showAddTeacherDialog(BuildContext context) {
    final userIdController = TextEditingController();
    final departmentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm Giảng viên mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: userIdController,
              decoration: const InputDecoration(labelText: 'User ID (Guid của người dùng)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: departmentController,
              decoration: const InputDecoration(labelText: 'Khoa / Bộ môn (Department)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final userId = userIdController.text.trim();
              final department = departmentController.text.trim();
              if (userId.isEmpty) return;

              final success = await _adminService.createTeacher({
                'userId': userId,
                'department': department,
              });

              if (!context.mounted) return;
              Navigator.pop(context);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thêm giảng viên thành công!')),
                );
                setState(() {
                  _loadData();
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thêm giảng viên thất bại!')),
                );
              }
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _showAddCourseDialog(BuildContext context) {
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final creditsController = TextEditingController(text: '3');
    final teacherIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm Môn học mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Mã môn học (VD: MMT101)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên môn học', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: creditsController,
                decoration: const InputDecoration(labelText: 'Số tín chỉ', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: teacherIdController,
                decoration: const InputDecoration(labelText: 'Giảng viên ID (tuỳ chọn)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = codeController.text.trim();
              final name = nameController.text.trim();
              final description = descriptionController.text.trim();
              final credits = int.tryParse(creditsController.text.trim()) ?? 3;
              final teacherId = int.tryParse(teacherIdController.text.trim());

              if (code.isEmpty || name.isEmpty) return;

              final Map<String, dynamic> body = {
                'code': code,
                'name': name,
                'description': description.isEmpty ? null : description,
                'credits': credits,
              };
              if (teacherId != null) {
                body['teacherId'] = teacherId;
              }

              final success = await _courseService.createCourse(body);

              if (!context.mounted) return;
              Navigator.pop(context);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thêm môn học thành công!')),
                );
                setState(() {
                  _loadData();
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thêm môn học thất bại!')),
                );
              }
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _showEditCourseDialog(BuildContext context, Map<String, dynamic> course) {
    final codeController = TextEditingController(text: course['code']);
    final nameController = TextEditingController(text: course['name']);
    final descriptionController = TextEditingController(text: course['description'] ?? '');
    final creditsController = TextEditingController(text: '${course['credits'] ?? 3}');
    final teacherIdController = TextEditingController(text: course['teacherId']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sửa Khóa học: ${course['code']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Mã môn học', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên môn học', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: creditsController,
                decoration: const InputDecoration(labelText: 'Số tín chỉ', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: teacherIdController,
                decoration: const InputDecoration(labelText: 'Giảng viên ID (tuỳ chọn)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = codeController.text.trim();
              final name = nameController.text.trim();
              final description = descriptionController.text.trim();
              final credits = int.tryParse(creditsController.text.trim()) ?? 3;
              final teacherId = int.tryParse(teacherIdController.text.trim());

              if (code.isEmpty || name.isEmpty) return;

              final Map<String, dynamic> body = {
                'code': code,
                'name': name,
                'description': description.isEmpty ? null : description,
                'credits': credits,
              };
              if (teacherId != null) {
                body['teacherId'] = teacherId;
              }

              final success = await _courseService.updateCourse(course['id'], body);

              if (!context.mounted) return;
              Navigator.pop(context);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cập nhật khóa học thành công!')),
                );
                setState(() {
                  _loadData();
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cập nhật khóa học thất bại!')),
                );
              }
            },
            child: const Text('Lưu thay đổi'),
          ),
        ],
      ),
    );
  }

  void _deleteCourse(int courseId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa khóa học này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _courseService.deleteCourse(courseId);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa khóa học thành công!')),
        );
        setState(() {
          _loadData();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa khóa học thất bại!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang Quản Trị Admin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              color: AppConstants.cardColor,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.defaultRadius)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Xin chào Quản trị viên!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppConstants.textColor)),
                    SizedBox(height: 8),
                    Text('Hệ thống quản lý điểm danh, môn học và giảng viên.', style: TextStyle(color: AppConstants.textColor)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Thống kê hệ thống', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textColor)),
            const SizedBox(height: 12),
            FutureBuilder<Map<String, dynamic>?>(
              future: _statsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Text('Không thể tải thống kê hệ thống.');
                }

                final stats = snapshot.data!;
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard('Sinh viên', '${stats['students'] ?? 0}', Icons.school, Colors.blue),
                    _buildStatCard('Giảng viên', '${stats['teachers'] ?? 0}', Icons.person_outline, Colors.orange),
                    _buildStatCard('Môn học', '${stats['courses'] ?? 0}', Icons.book, Colors.green),
                    _buildStatCard('Buổi học', '${stats['classSessions'] ?? 0}', Icons.event, Colors.purple),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(14)),
                    icon: const Icon(Icons.person_add_rounded),
                    label: const Text('Thêm Giảng viên'),
                    onPressed: () => _showAddTeacherDialog(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                      backgroundColor: AppConstants.secondaryColor,
                    ),
                    icon: const Icon(Icons.book_rounded),
                    label: const Text('Thêm Khóa học'),
                    onPressed: () => _showAddCourseDialog(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Quản lý Danh sách Khóa học', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textColor)),
            const SizedBox(height: 12),
            FutureBuilder<List<dynamic>>(
              future: _coursesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Chưa có môn học nào.');
                }
                final courses = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final c = courses[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.defaultRadius)),
                      child: ListTile(
                        leading: const Icon(Icons.menu_book_rounded, color: AppConstants.primaryColor),
                        title: Text('${c['code']} - ${c['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Tín chỉ: ${c['credits'] ?? 3} | GV: ${c['teacher'] ?? 'Chưa phân công'} | SV: ${c['studentCount'] ?? 0}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_rounded, color: Colors.blue),
                              onPressed: () => _showEditCourseDialog(context, c),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_rounded, color: Colors.red),
                              onPressed: () => _deleteCourse(c['id']),
                            ),
                          ],
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(color: AppConstants.secondaryColor.withAlpha(128)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppConstants.textColor)),
        ],
      ),
    );
  }
}
