// mobile/services/station_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/station.dart';

class StationService {
  static final String _baseUrl = dotenv.env['API_URL'] ?? '';

  static Future<List<Station>> getStationsByLocationId(int locationId) async {
    final uri = Uri.parse('$_baseUrl/Station/location/$locationId/stations');
    print('DEBUG: Đang gọi API điểm đón/trả theo Location ID: $uri');
    try {
      final response = await http.get(uri);
      print('DEBUG: Mã trạng thái phản hồi: ${response.statusCode}');
      print('DEBUG: Nội dung phản hồi: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Station.fromJson(json)).toList();
      } else {
        print('Failed to load stations: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load stations for location ID $locationId: ${response.body}');
      }
    } catch (e) {
      print('Error calling API to get stations: $e');
      throw Exception('Failed to connect to server to get stations.');
    }
  }

  static Future<List<Station>> getAllStations() async {
    final uri = Uri.parse('https://bobts-server-e7dxfwh7e5g9e3ad.malaysiawest-01.azurewebsites.net/api/Station?All=true');
    print('DEBUG: Đang gọi API lấy tất cả điểm đón/trả: $uri');
    try {
      final response = await http.get(uri);
      print('DEBUG: Mã trạng thái phản hồi (All Stations): ${response.statusCode}');
      print('DEBUG: Nội dung phản hồi (All Stations): ${response.body}');

      if (response.statusCode == 200) {
        // PHẦN SỬA ĐỔI CHỦ YẾU Ở ĐÂY
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        // Kiểm tra xem khóa 'data' có tồn tại và là List không
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
          final List<dynamic> jsonList = jsonResponse['data'];
          return jsonList.map((json) => Station.fromJson(json)).toList();
        } else {
          // Xử lý trường hợp không tìm thấy khóa 'data' hoặc nó không phải là List
          throw Exception('Invalid API response format: "data" key not found or not a list.');
        }
      } else {
        print('Failed to load all stations: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load all stations: ${response.body}');
      }
    } catch (e) {
      print('Error calling API to get all stations: $e');
      throw Exception('Failed to connect to server to get all stations.');
    }
  }
}