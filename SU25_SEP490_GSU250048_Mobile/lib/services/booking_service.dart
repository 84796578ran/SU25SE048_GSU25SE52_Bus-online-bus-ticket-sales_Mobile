import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/models/trip.dart';
import 'package:mobile/services/author_service.dart';

class BookingService {
  static final String _baseUrl = dotenv.env['API_URL'] ?? '';
  static Future<List<Trip>> searchOneWayTrip({
      required String fromLocation,
      required String endLocation,
      required  DateTime timeStart,
      //required int totalNumber
  }) async {
    final token = await AuthService.getToken();
    final uri = Uri.parse('$_baseUrl/Trip/search');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'fromLocation': fromLocation,
        'endLocation': endLocation,
        'timeStart': timeStart.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> rawList = jsonDecode(response.body);
      return rawList.map((e) => Trip.fromJson(e)).toList();
    } else {
      throw Exception(
          'Không tìm được chuyến xe. ${response.statusCode}');
    }
  }

  static Future<List<Trip>> searchRoundTrip({
    required String fromLocation,
    required String endLocation,
    required DateTime timeStart,
    //required int totalNumber,
    bool isRoundTrip = false,
    DateTime? returnDate,
  }) async {
    final token = await AuthService.getToken();
    final uri = Uri.parse('$_baseUrl/Trip/search');

    final Map<String, dynamic> payload = {
      'fromLocation': fromLocation,
      'endLocation': endLocation,
      'timeStart': timeStart.toIso8601String(),
    //  'totalNumber': totalNumber,
      'isRoundTrip': isRoundTrip,
    };

    // 👇 Chỉ thêm returnDate nếu chọn khứ hồi
    if (isRoundTrip && returnDate != null) {
      payload['returnDate'] = returnDate.toIso8601String();
    }

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final List<dynamic> rawList = jsonDecode(response.body);
      return rawList.map((e) => Trip.fromJson(e)).toList();
    } else {
      throw Exception('Không tìm được chuyến xe. ${response.statusCode}');
    }
  }
}
