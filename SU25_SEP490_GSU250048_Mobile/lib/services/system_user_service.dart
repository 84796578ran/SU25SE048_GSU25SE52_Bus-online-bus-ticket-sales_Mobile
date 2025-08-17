// lib/services/system_user_service.dart
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';

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
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      final idStr = payload["nameid"];
      if (idStr != null) {
        final id = int.tryParse(idStr.toString());
        if (id != null) {
          await prefs.setInt(_systemUserIdKey, id);
          print("SystemUserId lưu vào SharedPreferences: $id");
        }
      } else {
        debugPrint("⚠️ Token không có field 'nameid'");
      }
    } catch (e) {
      print('Lỗi khi decode token: $e');
    }
  }


  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveSystemUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_systemUserIdKey, id);
    print("✅ SystemUserId được lưu thủ công vào SharedPreferences: $id");
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


}