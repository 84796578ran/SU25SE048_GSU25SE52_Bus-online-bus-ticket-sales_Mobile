import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/location.dart'; // Đảm bảo đây là model Location của Tỉnh/Thành phố (có id và name)
import '../services/author_service.dart'; // Cần import nếu API Location yêu cầu token

class LocationService {
  static final String _baseUrl = dotenv.env['API_URL'] ?? '';

  // để điền vào ProvinceDropdown.
  static Future<List<Location>> getProvinces() async {
    final uri = Uri.parse('$_baseUrl/Location?All=true');
    // Lấy token nếu API /Location yêu cầu xác thực
    // final token = await AuthService.getToken(); // Bỏ comment nếu cần token

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // Thêm Authorization header nếu API này cần xác thực
          // if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
          final List<dynamic> rawList = jsonResponse['data'];
          List<Location> locations = rawList.map((json) => Location.fromJson(json)).toList();
          locations.sort((a, b) => a.name.compareTo(b.name));
          return locations;
        } else {
          print('Phản hồi API không có khóa "data" hoặc "data" không phải là danh sách: ${response.body}');
          throw Exception('Cấu trúc phản hồi API không hợp lệ cho danh sách tỉnh.');
        }
      } else {
        print('Lỗi khi tải danh sách tỉnh (Status: ${response.statusCode}): ${response.body}');
        try {
          final Map<String, dynamic> errorResponse = json.decode(response.body);
          throw Exception('Lỗi khi tải danh sách tỉnh: ${errorResponse['message'] ?? 'Lỗi không xác định'}');
        } catch (_) {
          throw Exception('Lỗi khi tải danh sách tỉnh. Mã lỗi: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Lỗi gọi API để lấy danh sách tỉnh: $e');
      if (e.toString().contains('Failed host lookup') || e.toString().contains('Connection refused')) {
        throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối internet hoặc URL API.');
      } else {
        throw Exception('Lỗi xử lý dữ liệu khi lấy danh sách tỉnh: $e');
      }
    }
  }
}