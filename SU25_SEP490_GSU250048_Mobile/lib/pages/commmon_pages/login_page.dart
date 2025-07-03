import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/customer.dart';
import 'package:mobile/pages/customer_pages/provider_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class LoginPage extends StatefulWidget {
  static const path = '/login';
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }



  void fetchData() async {
    final uri = Uri.parse('http://10.0.2.2:7197/api/Customer/LoginWithPhone');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final customer = Customer.fromJson(data);

      print('Đăng nhập thành công: $customer');
      // if (mounted) {
      //   context.go('/provider/home');
      // }
    } else {
      print('Đăng nhập thất bại với mã ${response.statusCode}');
      // Có thể hiển thị thông báo lỗi bằng SnackBar hoặc AlertDialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sai tên đăng nhập hoặc mật khẩu. Vui kiểm tra lại.'))
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/Logo.png',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  hintText: 'Số điện thoại',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  hintText: 'Mật khẩu',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.lock), // Icon khóa
                ),
              ),
              const SizedBox(height: 35),
              ElevatedButton(
                onPressed: () {
                  final String username = _usernameController.text;
                  final String password = _passwordController.text;
                  print('Username: $username');
                  print('Password: $password');
                  context.go('/provider/home');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Đăng nhập'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
