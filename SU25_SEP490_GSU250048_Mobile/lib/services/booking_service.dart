// lib/services/booking_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class BookingService {
  final String _baseUrl = dotenv.env['API_URL'] ?? '';
  final String _endpoint = '/Reservations';

  Future<Map<String, dynamic>> createReservation(Map<String, dynamic> payload, {Map<String, dynamic>? queryParams}) async {
    // Tạo URI ban đầu
    Uri uri = Uri.parse('$_baseUrl$_endpoint');

    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())));
    }

    print('Sending payment request to: $uri');
    print('Request body: ${json.encode(payload)}');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );
      return {
        'statusCode': response.statusCode,
        'body': json.decode(response.body),
      };
    } catch (e) {
      // Xử lý lỗi kết nối
      return {
        'statusCode': 500,
        'body': {'error': 'Lỗi kết nối: $e'},
      };
    }
  }
}