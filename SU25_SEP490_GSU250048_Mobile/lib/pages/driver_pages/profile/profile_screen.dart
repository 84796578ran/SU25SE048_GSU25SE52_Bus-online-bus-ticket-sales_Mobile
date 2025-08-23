import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../provider/systemUser_provider.dart';
import '../../commmon_pages/login_page.dart';

class DriverProfileScreen extends StatelessWidget {
  static const path = '/driver/profile';

  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final systemAuthProvider = Provider.of<SystemUserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange.shade800,
      ),
      body: Consumer<SystemUserProvider>(
        builder: (context, systemUser, child) {
          if (!systemUser.isLoggedIn) {
            // Nếu người dùng chưa đăng nhập, chuyển hướng về trang đăng nhập
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(LoginPage.path);
            });
            return const SizedBox.shrink();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.person, size: 80, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileInfoRow(
                          icon: Icons.badge_outlined,
                          label: 'Tên đăng nhập:',
                          value: systemAuthProvider.userName ?? 'Đang cập nhật',
                        ),
                        const Divider(height: 20),
                        _buildProfileInfoRow(
                          icon: Icons.local_taxi_outlined,
                          label: 'Vai trò:',
                          value: systemAuthProvider.role ?? 'Đang cập nhật',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    await systemUser.logout();
                    // Điều hướng về trang đăng nhập sau khi đăng xuất
                    context.go(LoginPage.path);
                  },
                  child: const Text(
                    'Đăng xuất',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileInfoRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange.shade800),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}