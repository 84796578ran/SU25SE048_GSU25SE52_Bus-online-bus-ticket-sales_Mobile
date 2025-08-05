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
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Company.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi khi gọi API: ${response.statusCode}');
      }
    } catch (e) {
      print(' Lỗi khi fetch popular companies: $e');
      throw Exception('Netword error.');
    }
  }
}
