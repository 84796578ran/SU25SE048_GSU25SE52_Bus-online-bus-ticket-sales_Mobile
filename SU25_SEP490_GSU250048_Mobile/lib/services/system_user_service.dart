// lib/services/system_user_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SystemUserService {
  static const _tokenKey = 'system_user_auth_token';
  static const _systemUserIdKey = 'system_user_id';
  static const _userNameKey = 'system_user_name';
  static const _roleKey = 'system_user_role';

  static String _baseUrl = dotenv.env['API_URL'] ?? '';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    try {
      final payload = Jwt.parseJwt(token);
      final idStr = payload["nameid"]?.toString();
      final id = idStr != null ? int.tryParse(idStr) : null;
      if (id != null) {
        await prefs.setInt(_systemUserIdKey, id);
        print(" Lưu systemUserId thành công: $id");
      } else {
        print("Không tìm thấy systemUserId trong token");
      }
      final userName = payload["unique_name"]?.toString();
      if (userName != null && userName.isNotEmpty) {
        await prefs.setString(_userNameKey, userName);
      }

      final role = payload["role"]?.toString();
      if (role != null && role.isNotEmpty) {
        await prefs.setString(_roleKey, role);
      }
    } catch (e) {
      print(" Lỗi khi decode token: $e");
    }
  }


  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<int?> getSystemUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_systemUserIdKey);
  }

  static Future<void> saveUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, userName);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_systemUserIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_roleKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    final uri = Uri.parse('$_baseUrl/SystemUser/login');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('Lỗi khi đăng nhập SystemUser: $e');
      return null;
    }
  }

// Tùy chọn: Thêm phương thức để lấy thông tin SystemUser từ API
// static Future<SystemUser?> getSystemUser(int systemUserId) async {
// Viết logic gọi API để lấy thông tin SystemUser
// final uri = Uri.parse('$_baseUrl/SystemUser/$systemUserId');
// final response = await http.get(uri);
// if (response.statusCode == 200) {
//   return SystemUser.fromJson(json.decode(response.body));
// }
//   return null;
// }
}