class Station {
  final String stationId;
  final String name;
  final int locationId;
  final String? status;
  final bool? isDeleted;
  Station({
    required this.stationId,
    required this.name,
    required this.locationId,
    this.status,
    this.isDeleted,
  });
  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(

      stationId: json['stationId'],
      name: json['name'],
      locationId: json['locationId'],
      status: json['status'],
      isDeleted: json['isDeleted'],

    );
  }

  Map<String, dynamic> toJson() {
    return {

      'stationId': stationId,
      'name': name,
      'locationId': locationId,
      'status': status,
      'isDeleted': isDeleted,

    };
  }
}
