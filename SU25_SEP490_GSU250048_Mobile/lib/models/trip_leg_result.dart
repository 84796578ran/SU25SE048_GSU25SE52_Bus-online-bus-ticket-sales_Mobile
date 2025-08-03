import 'package:mobile/models/trip.dart';
import 'package:mobile/models/TransferTrip.dart';

class TripLegResult {
  final bool isDirect;
  final List<Trip> directTrips;
  final List<TransferTrip> transferTrips;
  final List<Trip> tripleTrips; // Giả định tripleTrips cũng là List<Trip>

  TripLegResult({
    required this.isDirect,
    required this.directTrips,
    required this.transferTrips,
    required this.tripleTrips,
  });

  factory TripLegResult.fromJson(Map<String, dynamic> json) {
    return TripLegResult(
      isDirect: json['isDirect'] as bool? ?? false,
      directTrips: (json['directTrips'] as List<dynamic>?)
          ?.map((e) => Trip.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      transferTrips: (json['transferTrips'] as List<dynamic>?)
          ?.map((e) => TransferTrip.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      tripleTrips: (json['tripleTrips'] as List<dynamic>?)
          ?.map((e) => Trip.fromJson(e as Map<String, dynamic>)) // Giả định đây là Trip
          .toList() ??
          [],
    );
  }
}