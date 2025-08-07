import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _customerIdKey = 'customer_id';
  static const _phoneKey = 'phone';
  static const _userNameKey = 'user_name';
  static final String _baseUrl = dotenv.env['API_URL'] ?? '';
  static final String _endpoint = '/Customers/Registration';

  static Future<void> savePhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phoneKey, phone);
  }

  static Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  static Future<void> saveUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, userName);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    try {
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      final idStr = payload["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"];
      if (idStr != null) {
        final id = int.tryParse(idStr.toString());
        if (id != null) {
          await prefs.setInt(_customerIdKey, id);
          print(' Saved customerId: $id');
        } else {
          print(' Không thể parse customerId từ token');
        }
      } else {
        print(' Không tìm thấy claim customerId trong token');
      }
    } catch (e) {
      print(' Lỗi khi decode token: $e');
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<int?> getCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_customerIdKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_customerIdKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  static Future<bool> registerCustomer({required String fullName, required String email, required String phone, required String password}) async {
    final Uri uri = Uri.parse('$_baseUrl$_endpoint');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'fullName': fullName, 'email': email, 'phone': phone, 'password': password}),
      );
      if (response.statusCode == 200) {
        print('Đăng ký thành công!');
        return true;
      } else {
        // Đăng ký thất bại, in thông tin lỗi
        print('Đăng ký thất bại với status code: ${response.statusCode}');
        print('Lý do: ${response.body}');
        return false;
      }
    } catch (e) {
      // Xử lý lỗi kết nối
      print('Lỗi kết nối khi đăng ký: $e');
      return false;
    }
  }
}
