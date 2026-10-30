import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/auth.dart';
import '../../utils/constants.dart';
import '../../utils/storage.dart';
import '../student/student_dashboard.dart';
import '../staff/staff_dashboard.dart';
import '../admin/admin_dashboard.dart';
import 'registration_screen.dart';

/// Màn hình Đăng nhập (Aligned with Dashboards & Classic Theme)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailOrUsernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    final result = await _authService.login(
      _emailOrUsernameController.text.trim(),
      _passwordController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      final token = await Storage.getToken();
      if (!mounted) return;

      String role = 'student';
      if (token != null) {
        role = AuthUtils.getRole(token) ?? 'student';
      }

      Widget nextScreen;
      if (role.toLowerCase() == 'admin') {
        nextScreen = const AdminDashboard();
      } else if (role.toLowerCase() == 'staff' || role.toLowerCase() == 'teacher') {
        nextScreen = const StaffDashboard();
      } else {
        nextScreen = const StudentDashboard();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextScreen),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng nhập thất bại: ${result['message']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập Hệ thống Điểm danh')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school_rounded, size: 80, color: AppConstants.primaryColor),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailOrUsernameController,
                  decoration: const InputDecoration(
                    labelText: 'Email hoặc Tên đăng nhập',
                    prefixIcon: Icon(Icons.person_outline, color: AppConstants.secondaryColor),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppConstants.secondaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Đăng nhập', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                    );
                  },
                  child: const Text(
                    'Chưa có tài khoản? Đăng ký ngay',
                    style: TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
