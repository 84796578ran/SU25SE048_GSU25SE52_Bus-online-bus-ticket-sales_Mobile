

class StationPassengerCount {
  final int tripStationId;
  final String stationName;
  final int passengerCount;

  StationPassengerCount({
    required this.tripStationId,
    required this.stationName,
    required this.passengerCount,
  });

  factory StationPassengerCount.fromJson(Map<String, dynamic> json) {
    return StationPassengerCount(
      tripStationId: json['tripStationId'] as int,
      stationName: json['stationName'] as String,
      passengerCount: json['passengerCount'] as int,
    );
  }
}