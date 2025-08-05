// mobile/models/station.dart

class Station {
  final int id;             // Ánh xạ từ "id" (int) trong JSON
  final String stationId;   // Ánh xạ từ "stationId" (String) trong JSON
  final String name;        // Ánh xạ từ "name" (String) trong JSON
  final String locationName; // Ánh xạ từ "locationName" (String) trong JSON



  Station({
    required this.id,
    required this.stationId,
    required this.name,
    required this.locationName,


  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: (json['id'] as int?) ?? 0, // Giá trị mặc định là 0 nếu null
      stationId: (json['stationId'] as String?) ?? 'N/A', // Giá trị mặc định là 'N/A' nếu null
      name: (json['name'] as String?) ?? 'N/A', // Giá trị mặc định là 'N/A' nếu null
      locationName: (json['locationName'] as String?) ?? 'N/A', // Giá trị mặc định là 'N/A' nếu null


    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stationId': stationId,
      'name': name,
      'locationName': locationName,


    };
  }
}