import 'package:flutter/material.dart';
import 'package:mobile/provider/author_provider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  static final path = "/profile";
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        centerTitle: true,
      ),
      body: auth.isLoggedIn
          ? SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: auth.avatarUrl != null
                  ? NetworkImage(auth.avatarUrl!)
                  : const AssetImage('assets/avatar_placeholder.png')
              as ImageProvider,
            ),
            const SizedBox(height: 16),
            Text(
              'Token: ${auth.token ?? "(Không có token)"}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // 🚌 Placeholder chuyến xe
            Align(
              alignment: Alignment.centerLeft,
              child: Text('🚌 Chuyến xe đã đặt',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.directions_bus),
                title: const Text('Cần Thơ → Hà Nội'),
                subtitle: const Text('Khởi hành: 14:00 | Ghế B2'),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                await auth.logout();
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
