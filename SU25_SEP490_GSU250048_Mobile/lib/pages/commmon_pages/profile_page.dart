import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/provider/author_provider.dart';
import 'package:mobile/services/author_service.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/pages/customer_pages/screens/history/history_screen.dart'; // Import HistoryScreen


class ProfilePage extends StatelessWidget {
  static final path = '/profile';
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xff447def),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xff447def),
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 20, bottom: 40),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 60, color: Color(0xff447def)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    authProvider.userName ?? 'Chưa có tên',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    authProvider.phone ?? 'Chưa có số điện thoại',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Nút "Sửa thông tin cá nhân"
                      ListTile(
                        leading: const Icon(Icons.edit, color: Color(0xff447def)),
                        title: const Text(
                          'Xem thông tin cá nhân',
                          style: TextStyle(fontSize: 16),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Điều hướng đến màn hình chỉnh sửa thông tin
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(content: Text('Chức năng sửa thông tin chưa được triển khai.')),
                          // );
                        },
                      ),
                      const Divider(),

                      // Nút "Lịch sử thanh toán"
                      ListTile(
                        leading: const Icon(Icons.history, color: Color(0xff447def)),
                        title: const Text(
                          'Lịch sử thanh toán',
                          style: TextStyle(fontSize: 16),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          context.go(HistoryScreen.path); // Điều hướng đến màn hình lịch sử vé
                        },
                      ),
                      const Divider(),

                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await authProvider.logout();
                            context.go('/login');
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Đăng xuất'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red.shade400,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}