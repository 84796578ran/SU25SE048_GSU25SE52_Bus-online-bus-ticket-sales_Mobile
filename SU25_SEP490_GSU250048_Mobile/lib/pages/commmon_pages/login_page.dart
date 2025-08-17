import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/services/system_user_service.dart';
import 'package:provider/provider.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../provider/author_provider.dart';
import '../../provider/systemUser_provider.dart';
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
    if (kDebugMode) {
      _phoneController.text = '0938080462';
      _passwordController.text = '18012003';
    }
    _checkIfLoggedIn();
  }

  Future<void> _checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null && mounted) {
      try {
        final payload = JwtDecoder.decode(token);
        final actor = payload['actor'];
        final role = payload['role'];

        if (actor == 'system' && role == 'driver') {
          context.go('/driver/home');
        } else {
          context.go('/customer/home');
        }
      } catch (e) {
        print('Lỗi token: $e');
        await AuthService.clearToken();
      }
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

    final loginInput = _phoneController.text.trim();
    final isEmail = loginInput.contains('@');

    try {
      if (isEmail) {

        final uri = Uri.parse('${dotenv.env['API_URL']}/SystemUser/login');

        final response = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': loginInput, // Giữ nguyên 'email' theo yêu cầu của bạn
            'password': _passwordController.text.trim(),
          }),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final token = responseData['token'];
          if (token == null || token is! String || token.isEmpty) {
            throw Exception('Token không hợp lệ');
          }
          await SystemUserService.saveToken(token);
          final systemUserProvider = Provider.of<SystemUserProvider>(context, listen: false);
          await SystemUserService.saveUserName('system_user_name');
          await SystemUserService.saveRole('system_user_role');
          await systemUserProvider.login(token);
          print('SystemUserId từ provider: ${systemUserProvider.systemUserId}');
          // Nếu muốn in trực tiếp từ SharedPreferences (do saveToken đã lưu sẵn)
          final savedId = await SystemUserService.getSystemUserId();
          print('SystemUserId từ SharedPreferences: $savedId');
          context.go('/driver/home');

        } else {
          // Thử đăng nhập bằng email của Customer nếu đăng nhập SystemUser thất bại
          final customerGmailUri = Uri.parse('${dotenv.env['API_URL']}/Customers/LoginWithGmail');
          final customerGmailResponse = await http.post(
            customerGmailUri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'gmail': loginInput,
              'password': _passwordController.text.trim(),
            }),
          );
          if (customerGmailResponse.statusCode == 200) {
            final responseData = jsonDecode(customerGmailResponse.body);
            final token = responseData['token'];
            if (token == null || token is! String || token.isEmpty) {
              throw Exception('Token không hợp lệ');
            }
            print('Toàn bộ body: ${response.body}');
            await AuthService.saveToken(token);
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            authProvider.updatePhone(responseData['phone']);
            await AuthService.savePhone(responseData['phone']);
            await AuthService.saveUserName(responseData['fullName']);
            await authProvider.login(token);
            context.go('/customer/home');
          } else {
            _showErrorDialog(context, 'Sai email hoặc mật khẩu. Vui lòng thử lại.');
          }
        }
      } else {
        // Nhánh 2: Đăng nhập bằng số điện thoại (Customer)
        final uri = Uri.parse('${dotenv.env['API_URL']}/Customers/LoginWithPhone');

        final response = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'phone': loginInput,
            'password': _passwordController.text.trim(),
          }),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final token = responseData['token'];
          if (token == null || token is! String || token.isEmpty) {
            throw Exception('Token không hợp lệ');
          }
          print('Toàn bộ body: ${response.body}');
          await AuthService.saveToken(token);
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          authProvider.updatePhone(responseData['phone']);
          await AuthService.savePhone(responseData['phone']);
          await AuthService.saveUserName(responseData['fullName']);
          await authProvider.login(token);
          context.go('/customer/home');
        } else {
          _showErrorDialog(context, 'Sai số điện thoại hoặc mật khẩu. Vui lòng thử lại.');
        }
      }
    } catch (e) {
      print('Lỗi khi gọi API: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kết nối mạng bị lỗi. Vui lòng thử lại sau !!!')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

// Hàm trợ giúp để hiển thị dialog lỗi
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đăng nhập thất bại'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('Đóng'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView( // 👈 Thêm dòng này
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 80, 24, 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 👈 nên bỏ dòng này (giải thích ở dưới)
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset('assets/Logo.png', width: 170, height: 170),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Chào mừng bạn đến với',
                    style: TextStyle(fontSize: 28),
                  ),
                ),
                const Center(
                  child: Text(
                    'XE TIỆN ÍCH',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Gmail hoặc Số điện thoại',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Quên mật khẩu?',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 30),
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
                const SizedBox(height: 20),
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
        ),
      ),
    );
  }

}
