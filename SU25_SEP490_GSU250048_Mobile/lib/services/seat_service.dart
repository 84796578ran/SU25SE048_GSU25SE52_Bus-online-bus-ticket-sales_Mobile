import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/seat.dart'; // Import the updated Seat model
// import '../services/author_service.dart'; // Uncomment if this API also requires an authorization token

class SeatService {
  static final String _baseUrl = dotenv.env['API_URL'] ?? '';

  /// Fetches seat availability for a specific trip between two stations.
  ///
  /// [tripId] The ID of the trip.
  /// [fromStationId] The ID of the departure station.
  /// [toStationId] The ID of the arrival station.
  ///
  /// Returns a List of Seat objects indicating their availability.
  /// Throws an Exception if the API call fails or the response is invalid.
  static Future<List<Seat>> getSeatAvailability({
    required int tripId,
    required int fromStationId,
    required int toStationId,
  }) async {
    final uri = Uri.parse('$_baseUrl/Trip/$tripId/seat-availability?fromStationId=$fromStationId&toStationId=$toStationId');
    print('DEBUG: Calling Seat Availability API: $uri');

    // Uncomment and use if your API requires an Authorization token
    // final token = await AuthService.getToken();

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // if (token != null) 'Authorization': 'Bearer $token', // Uncomment if needed
        },
      );

      print('DEBUG: Seat Availability Status Code: ${response.statusCode}');
      print('DEBUG: Seat Availability Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body); // Directly decode as a List
        return jsonList.map((json) => Seat.fromJson(json)).toList();
      } else {
        String errorMessage = 'Failed to load seat availability. Status: ${response.statusCode}';
        try {
          final Map<String, dynamic> errorResponse = json.decode(response.body);
          errorMessage = errorResponse['message'] ?? errorMessage;
        } catch (_) {
          // If response body is not valid JSON, use generic error message
        }
        print('ERROR: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('ERROR: Error calling Seat Availability API: $e');
      if (e.toString().contains('Failed host lookup') || e.toString().contains('Connection refused')) {
        throw Exception('Cannot connect to the server. Please check your internet connection or API URL.');
      } else {
        throw Exception('Error processing seat availability data: $e');
      }
    }
  }
}