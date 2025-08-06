import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/ticket.dart';
import 'author_service.dart'; // để lấy token

class TicketService {
  static Future<List<Ticket>> fetchTicketHistory() async {
    final baseUrl = dotenv.env['API_URL'];
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Không tìm thấy token. Người dùng chưa đăng nhập?');
    }

    final url = Uri.parse('$baseUrl/Ticket/customer/tickets');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Ticket.fromJson(json)).toList();
    } else {
      print('Lỗi API: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load ticket history');
    }
  }
}
