// lib/services/company_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/company.dart';

class CompanyService {
  static final String baseURL = dotenv.env['API_URL'] ?? '';

  static Future<List<Company>> fetchPopularCompanies() async {
    final url = Uri.parse('$baseURL/Company/popular');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> companiesJson = responseData['data'];
        return companiesJson.map((json) => Company.fromJson(json)).toList();
      } else {
        // Xử lý lỗi từ server (ví dụ: 404, 500)
        print('Lỗi khi gọi API: ${response.statusCode} - ${response.body}');
        throw Exception('Không thể tải dữ liệu, vui lòng thử lại!!!');
      }
    } catch (e) {
      // Xử lý lỗi kết nối mạng
      print('Lỗi khi fetch popular companies: $e');
      throw Exception('Không thể tải dữ liệu, vui lòng thử lại!!!');
    }
  }
}