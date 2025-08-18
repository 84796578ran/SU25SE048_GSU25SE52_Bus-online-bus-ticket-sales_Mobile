import 'package:mobile/models/trip_leg_result.dart';

class RoundTripResult {
  final bool isValid;
  final String? errorMessage;
  final TripLegResult departure;
  final TripLegResult returnTrip; // Đổi tên 'return' thành 'returnTrip' để tránh từ khóa

  RoundTripResult({
    required this.isValid,
    this.errorMessage,
    required this.departure,
    required this.returnTrip,
  });

  factory RoundTripResult.fromJson(Map<String, dynamic> json) {
    return RoundTripResult(
      isValid: json['isValid'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
      departure: TripLegResult.fromJson(json['departure'] as Map<String, dynamic>),
      returnTrip: TripLegResult.fromJson(json['return'] as Map<String, dynamic>), // Vẫn parse từ 'return' của JSON
    );
  }
}