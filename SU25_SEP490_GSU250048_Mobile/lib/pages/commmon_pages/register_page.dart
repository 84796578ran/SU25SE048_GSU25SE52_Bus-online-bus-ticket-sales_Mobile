import 'package:flutter/material.dart';

import '../../services/author_service.dart';
import '../../widget/SuccessDialog.dart';

class RegisterPage extends StatefulWidget {
  static final path = '/register';
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Trong _RegisterPageState
  void _handleRegister() async {
    final fullName = _fullNameController.text;
    final email = _emailController.text;
    final phone = _phoneController.text;
    final password = _passwordController.text;

    // Hiển thị một vòng tròn loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await AuthService.registerCustomer(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
    );

    Navigator.of(context).pop();

    if (success) {
      SuccessDialog.show(
        context,
        title: 'Chúc mừng!',
        message: 'Bạn đã đăng ký tài khoản thành công.',
        redirectPath: '/login',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thất bại. Vui lòng thử lại.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          //mainAxisAlignment: MainAxisAlignment.end,
          children: [

       // Khoảng trống giữa logo và chữ
            const Text('Đăng ký tài khoản mới'),
            // const SizedBox(width: 10),
            // Image.asset(
            //   'assets/Logo.png',
            //   height: 50, // Điều chỉnh kích thước logo theo ý muốn
            // ),
          ],
        ),
        backgroundColor: Colors.pinkAccent.shade100,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              'Tạo tài khoản mới',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent.shade100,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Trường nhập Full Name
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'Họ và Tên',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20), // Giá trị 20 sẽ bo tròn nhiều hơn
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),

            // Trường nhập Email
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20), // Giá trị 20 sẽ bo tròn nhiều hơn
                ),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // Trường nhập Phone Number
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20), // Giá trị 20 sẽ bo tròn nhiều hơn
                ),
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            // Trường nhập Password
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20), // Giá trị 20 sẽ bo tròn nhiều hơn
                ),
                prefixIcon: const Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 40),


            ElevatedButton.icon(
              onPressed: _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent.shade100,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              label: const Text(
                'Đăng ký',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}