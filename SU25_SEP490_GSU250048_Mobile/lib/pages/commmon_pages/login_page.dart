import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../provider/author_provider.dart';
import '../../services/author_service.dart';

class LoginPage extends StatefulWidget {
  static const path = '/login';
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  Future<void> _checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null && mounted) {
      context.go('/customer/home');
    }
  }


  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    setState(() => _isLoading = true);
    final uri = Uri.parse('${dotenv.env['API_URL']}/Customer/LoginWithPhone');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone': _phoneController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );
      if (response.statusCode == 200) {
        final token = response.body;
        await AuthService.saveToken(token);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.login(token);
        final payload = JwtDecoder.decode(token);
        final actor = payload['actor'];
        final role = payload['role'];

        print('Actor: $actor, Role: $role');
        if (actor == 'system' && role == 'driver') {
          context.go('/driver/home');
        } else {
          context.go('/customer/home');
        }
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sai số điện thoại hoặc mật khẩu.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Lỗi khi gọi API: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể kết nối đến máy chủ.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/Logo.png', width: 170, height: 170),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chào mừng bạn đến với', style: TextStyle(fontSize: 28)),
                Text(
                  'XE TIỆN ÍCH',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const SizedBox(height: 20),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Số điện thoại',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 40),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Quên mật khẩu?',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _login(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff447def),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Đăng nhập',
                  style: TextStyle(fontSize: 22, color: Colors.white),
                ),
              ),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Chưa có tài khoản?', style: TextStyle(fontSize: 18)),
                SizedBox(width: 6),
                Text('Đăng ký ngay', style: TextStyle(fontSize: 18, color: Colors.blue)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
