import 'package:mobile/models/passenger.dart'; // Import model Passenger

class StationPassengerCount {
  final int tripStationId;
  final String stationName;
  final int passengerCount;
  final List<Passenger> passengers;

  StationPassengerCount({
    required this.tripStationId,
    required this.stationName,
    required this.passengerCount,
    required this.passengers,
  });

  factory StationPassengerCount.fromJson(Map<String, dynamic> json) {
    // Chuyển đổi danh sách JSON thành danh sách các đối tượng Passenger
    final List<dynamic> passengerList = json['passengers'] as List<dynamic>;
    final List<Passenger> passengers =
    passengerList.map((p) => Passenger.fromJson(p as Map<String, dynamic>)).toList();

    return StationPassengerCount(
      tripStationId: json['tripStationId'] as int,
      stationName: json['stationName'] as String,
      passengerCount: json['passengerCount'] as int,
      passengers: passengers,
    );
  }
}