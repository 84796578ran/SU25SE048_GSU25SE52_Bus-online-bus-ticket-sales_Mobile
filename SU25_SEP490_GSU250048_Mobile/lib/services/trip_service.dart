import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/models/trip.dart';
import 'package:mobile/models/TransferTrip.dart';
import 'package:mobile/services/author_service.dart';
import 'package:intl/intl.dart';
import '../models/RoundTripResult.dart';
import '../provider/author_provider.dart';

class TripServices {
  static final String _baseUrl = dotenv.env['API_URL'] ?? '';

  static List<dynamic> _parseTripSearchResponse(Map<String, dynamic> decodedJson) {
    List<dynamic> results = [];
    if (decodedJson.containsKey('directTrips') && decodedJson['directTrips'] is List) {
      final List<dynamic> directTripsJson = decodedJson['directTrips'];
      results.addAll(directTripsJson.map((e) => Trip.fromJson(e as Map<String, dynamic>)).toList());
    }
    if (decodedJson.containsKey('transferTrips') && decodedJson['transferTrips'] is List) {
      final List<dynamic> transferTripsJson = decodedJson['transferTrips'];
      results.addAll(transferTripsJson.map((e) => TransferTrip.fromJson(e as Map<String, dynamic>)).toList());
    }
    if (decodedJson.containsKey('tripleTrips') && decodedJson['tripleTrips'] is List) {
      final List<dynamic> tripleTripsJson = decodedJson['tripleTrips'];
      results.addAll(tripleTripsJson.map((e) => Trip.fromJson(e as Map<String, dynamic>)).toList());
    }
    return results;
  }

  static Future<List<Trip>> getFutureTripsByCompany(int companyId) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Không có token xác thực. Vui lòng đăng nhập lại.');
    }

    final uri = Uri.parse('$_baseUrl/Trip/future/by-company/$companyId');
    print('DEBUG: Gọi API lấy chuyến tương lai theo công ty: $uri');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('DEBUG: Trạng thái phản hồi: ${response.statusCode}');
      print('DEBUG: Nội dung phản hồi: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((e) => Trip.fromJson(e)).toList();
      } else {
        print('ERROR: Lỗi lấy chuyến tương lai: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('ERROR: Lỗi kết nối khi lấy chuyến tương lai: $e');
      throw Exception('Lỗi kết nối đến máy chủ. Vui lòng thử lại. Chi tiết: $e');
    }
  }

  static Future<List<dynamic>> _performApiCall({
    required String endpoint,
    required Map<String, String> queryParams,
    required String requestType,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Không có token xác thực. Vui lòng đăng nhập lại.');
    }

    final uri = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: queryParams);
    print('DEBUG: Đang gọi API tìm chuyến $requestType: $uri');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('DEBUG: Mã trạng thái phản hồi tìm chuyến $requestType: ${response.statusCode}');
      print('DEBUG: Nội dung phản hồi tìm chuyến $requestType: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedJson = jsonDecode(response.body);
        return _parseTripSearchResponse(decodedJson);
      } else {
        print('ERROR: Lỗi khi tìm chuyến $requestType: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('ERROR: Lỗi kết nối khi tìm chuyến $requestType: $e');
      throw Exception('Lỗi kết nối đến máy chủ. Vui lòng thử lại. Chi tiết: $e');
    }
  }

  static Future<List<dynamic>> searchTrips({
    required int fromLocationId,
    required int fromStationId,
    required int toLocationId,
    required int toStationId,
    required DateTime date,
  }) async {
    final Map<String, String> fullQueryParams = {
      'FromLocationId': fromLocationId.toString(),
      'FromStationId': fromStationId.toString(),
      'ToLocationId': toLocationId.toString(),
      'ToStationId': toStationId.toString(),
      'Date': DateFormat('yyyy-MM-dd').format(date),
      'DirectTripsPagination.All': 'true',
      'TransferTripsPagination.All': 'true',
      'TripleTripsPagination.All': 'true',
    };
    return _performApiCall(
      endpoint: '/Trip/mobile-search',
      queryParams: fullQueryParams,
      requestType: 'chặt chẽ',
    );
  }

  static Future<List<dynamic>> searchTripsLoose({
    required int fromLocationId,
    required int toLocationId,
    required DateTime date,
  }) async {
    final Map<String, String> looseQueryParams = {
      'FromLocationId': fromLocationId.toString(),
      'ToLocationId': toLocationId.toString(),
      'Date': DateFormat('yyyy-MM-dd').format(date),
      'DirectTripsPagination.All': 'true',
      'TransferTripsPagination.All': 'true',
    };
    return _performApiCall(
      endpoint: '/Trip/search-location',
      queryParams: looseQueryParams,
      requestType: 'nới lỏng',
    );
  }

  static Future<List<dynamic>> searchOneWayTrip({
    required int departureStationId,
    required int arrivalStationId,
    required DateTime timeStart,
    required int fromLocationId,
    required int toLocationId,
  }) {
    return searchTrips(
      fromLocationId: fromLocationId,
      fromStationId: departureStationId,
      toLocationId: toLocationId,
      toStationId: arrivalStationId,
      date: timeStart,
    );
  }

  static Future<RoundTripResult> searchRoundTrip({
    required int fromLocationId,
    required int fromStationId,
    required int toLocationId,
    required int toStationId,
    required DateTime date,
    required DateTime returnDate,
  }) async {
    // ... logic khứ hồi không đổi ...
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Không có token xác thực. Vui lòng đăng nhập lại.');
    }

    final Map<String, String> queryParams = {
      'FromLocationId': fromLocationId.toString(),
      'FromStationId': fromStationId.toString(),
      'ToLocationId': toLocationId.toString(),
      'ToStationId': toStationId.toString(),
      'Date': DateFormat('yyyy-MM-dd').format(date),
      'ReturnDate': DateFormat('yyyy-MM-dd').format(returnDate),
      'DirectTripsPagination.All': 'true',
      'TransferTripsPagination.All': 'true',
      'TripleTripsPagination.All': 'true',
    };

    final uri = Uri.parse('$_baseUrl/Trip/mobile-search-return').replace(queryParameters: queryParams);
    print('DEBUG: Đang gọi API tìm chuyến khứ hồi: $uri');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('DEBUG: Mã trạng thái phản hồi tìm chuyến khứ hồi: ${response.statusCode}');
      print('DEBUG: Nội dung phản hồi tìm chuyến khứ hồi: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedJson = jsonDecode(response.body);
        return RoundTripResult.fromJson(decodedJson);
      } else {
        print('ERROR: Lỗi khi tìm chuyến khứ hồi: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Không tìm được chuyến xe khứ hồi. Lỗi: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('ERROR: Lỗi kết nối khi tìm chuyến khứ hồi: $e');
      throw Exception('Không thể kết nối đến máy chủ để tìm chuyến khứ hồi. Vui lòng thử lại. Chi tiết: $e');
    }
  }

}