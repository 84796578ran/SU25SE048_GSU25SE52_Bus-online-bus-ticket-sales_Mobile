// lib/services/rating_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/rating.dart';
import 'author_service.dart';
 // Import model RatingRequest

class RatingService {

  static final String _baseUrl = dotenv.env['API_URL'] ?? '';
  static const String _ratingEndpoint = '/Rating';

  static Future<bool> submitRating(Rating request) async {
    // Lấy token xác thực từ AuthService của bạn
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Không có token xác thực. Vui lòng đăng nhập lại.');
    }

    // Xây dựng URI đầy đủ cho API
    final Uri uri = Uri.parse('$_baseUrl$_ratingEndpoint');
    final Map<String, dynamic> requestBody = request.toJson();

    print('DEBUG: Đang gửi yêu cầu đánh giá đến: $uri');
    print('DEBUG: Request body: ${json.encode(requestBody)}');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      print('DEBUG: Mã trạng thái phản hồi API đánh giá: ${response.statusCode}');
      print('DEBUG: Nội dung phản hồi API đánh giá: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        // 200 OK hoặc 201 Created thường là dấu hiệu thành công
        return true;
      } else {
        String errorMessage = 'Lỗi khi gửi đánh giá: ${response.statusCode}';
        try {
          final Map<String, dynamic> errorResponse = json.decode(response.body);
          errorMessage += ' - ${errorResponse['message']?? errorResponse['errors']?? response.body}';
        } catch (e) {
          errorMessage += ' - ${response.body}'; // Nếu không parse được JSON lỗi
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('ERROR: Lỗi kết nối khi gửi đánh giá: $e');
      throw Exception('Không thể kết nối đến máy chủ để gửi đánh giá. Vui lòng thử lại.');
    }
  }
}