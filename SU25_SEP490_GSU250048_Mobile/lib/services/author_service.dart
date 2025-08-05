import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _customerIdKey = 'customer_id';

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
}
