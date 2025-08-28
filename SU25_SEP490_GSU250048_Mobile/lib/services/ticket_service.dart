import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/services/system_user_service.dart';
import '../models/stationPassengerCount.dart';
import '../models/ticket.dart';
import '../models/trip.dart';
import 'author_service.dart'; // để lấy token

class TicketService {
  static final _baseUrl = dotenv.env['API_URL'];
  static Future<List<Ticket>> fetchTicketHistory() async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Không tìm thấy token. Người dùng chưa đăng nhập?');
    }
    final url = Uri.parse('$_baseUrl/Ticket/customer/tickets');

    final response = await http.get(url, headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<Ticket> tickets = data
          .map((json) => Ticket.fromJson(json))
          .where((t) => [0, 1, 2, 5].contains(t.status))
          .toList();
      tickets.sort((a, b) => b.createDate.compareTo(a.createDate));
      return tickets;
    } else {
      print('Lỗi API: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load ticket history');
    }
  }

  static Future<Trip?> fetchTripByDriver(int driverId) async {
    final token = await SystemUserService.getToken();
    if (token == null) {
      throw Exception('Không tìm thấy token. Người dùng chưa đăng nhập?');
    }
    final uri = Uri.parse('$_baseUrl/Trip/by-driver/$driverId');
    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
       final responseBody = json.decode(response.body);
        final tripList = responseBody['data'] as List<dynamic>;

        if (tripList.isEmpty) {
          return null; // Trả về null nếu không có chuyến đi nào
        }
        final tripData = tripList.first;
        return Trip.fromJson(tripData);

      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load trip: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  static Future<List<StationPassengerCount>> fetchStationPassengerCount(int tripId) async {
    final uri = Uri.parse('$_baseUrl/Ticket/trip/$tripId/station-passenger-count');
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => StationPassengerCount.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load station passenger count: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  static Future<Map<String, dynamic>> checkTicket(String ticketId, int tripId) async {
    final token = await SystemUserService.getToken();
    if (token == null) {
      throw Exception('Không tìm thấy token. Người dùng chưa đăng nhập?');
    }

    final uri = Uri.parse('$_baseUrl/Ticket/check');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = json.encode({
      'ticketId': ticketId,
      'tripId': tripId,
    });

    try {
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['message'] ?? 'Lỗi không xác định.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Lỗi khi kết nối đến máy chủ: $e');
    }
  }

  static Future<void> completeTrip(int tripId) async {
    final token = await SystemUserService.getToken();
    if (token == null) {
      throw Exception('Không tìm thấy token. Người dùng chưa đăng nhập?');
    }

    final uri = Uri.parse('$_baseUrl/Trip/complete/$tripId');
    try {
      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print("Chuyến đi đã được hoàn thành thành công.");
      } else {
        print('Lỗi API: ${response.statusCode} - ${response.body}');
        throw Exception('Hoàn thành chuyến đi thất bại: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi kết nối đến máy chủ: $e');
    }
  }
}
