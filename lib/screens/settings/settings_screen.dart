import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_settings.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';

/// Màn hình Cài đặt (Thông tin tài khoản, Màu giao diện, Cỡ chữ)
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      _currentUser = user;
      _isLoadingUser = false;
    });
  }

  void _logout(BuildContext context) async {
    await _authService.logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeSettings = Provider.of<ThemeSettings>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt hệ thống')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            // Account Info Card
            const Text('Thông tin tài khoản', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textColor)),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.defaultRadius)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isLoadingUser
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: themeSettings.primaryColor,
                                child: Text(
                                  (_currentUser?.name.isNotEmpty == true) ? _currentUser!.name[0].toUpperCase() : 'U',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_currentUser?.name ?? 'Người dùng', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(_currentUser?.email ?? 'email@domain.com', style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Text('Vai trò: ${_currentUser?.role.toUpperCase() ?? 'STUDENT'}', style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Theme Color Customization
            const Text('Màu giao diện chủ đạo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textColor)),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.defaultRadius)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildColorOption(themeSettings, const Color(0xFFBA5A5A), 'Terracotta'),
                    _buildColorOption(themeSettings, const Color(0xFF3F51B5), 'Classic Blue'),
                    _buildColorOption(themeSettings, const Color(0xFF009688), 'Teal'),
                    _buildColorOption(themeSettings, const Color(0xFF673AB7), 'Purple'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Font Size Customization
            const Text('Cỡ chữ hiển thị', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textColor)),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.defaultRadius)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Nhỏ (0.85x)', style: TextStyle(fontSize: 14)),
                        Text('Chuẩn (1.0x)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: themeSettings.primaryColor)),
                        const Text('Lớn (1.15x)', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    Slider(
                      value: themeSettings.fontScale,
                      min: 0.85,
                      max: 1.15,
                      divisions: 2,
                      activeColor: themeSettings.primaryColor,
                      onChanged: (val) {
                        themeSettings.setFontScale(val);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Logout Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.all(16),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Đăng xuất tài khoản', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(ThemeSettings settings, Color color, String name) {
    final isSelected = settings.primaryColor == color;
    return GestureDetector(
      onTap: () => settings.setPrimaryColor(color),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.transparent,
                width: 3,
              ),
            ),
            child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
          ),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
