import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
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

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<Ticket> tickets = data.map((json) => Ticket.fromJson(json)).toList();
      tickets.sort((a, b) => b.createDate.compareTo(a.createDate));
      return tickets;
    } else {
      print('Lỗi API: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load ticket history');
    }
  }


  static Future<List<Trip>> fetchTripsByDriver(int driverId, String token) async {
    final uri = Uri.parse('$_baseUrl/Trip/by-driver/$driverId?All=true');
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> tripsData = data['trips'] ?? [];
      return tripsData.map((json) => Trip.fromJson(json)).toList();

    } else {
      throw Exception('Failed to fetch trips: ${response.statusCode}');
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

  static Future<Ticket> checkInTicket(String ticketId, int tripId) async {
    final uri = Uri.parse('$_baseUrl/check');

    final Map<String, dynamic> requestBody = {
      "ticketId": ticketId,
      "tripId": tripId,
    };
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return Ticket.fromJson(responseData);
      } else {
        throw Exception('Failed to check ticket. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }


}
