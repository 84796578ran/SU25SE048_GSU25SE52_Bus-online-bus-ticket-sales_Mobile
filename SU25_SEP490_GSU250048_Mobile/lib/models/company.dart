// lib/models/company.dart

class Company {
  final int id;
  final String companyId;
  final String name;
  final int numberOfRatings;
  final double averageRating;
  final int numberOfTrips;

  Company({
    required this.id,
    required this.companyId,
    required this.name,
    required this.numberOfRatings,
    required this.averageRating,
    required this.numberOfTrips,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as int? ?? 0,
      companyId: json['companyId'] as String? ?? '',
      name: json['name'] as String? ?? 'N/A',
      numberOfRatings: json['numberOfRatings'] as int? ?? 0,
      averageRating: (json['averageRating'] as num? ?? 0.0).toDouble(),
      numberOfTrips: json['numberOfTrips'] as int? ?? 0,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'name': name,
      'numberOfRatings': numberOfRatings,
      'averageRating': averageRating,
      'numberOfTrips': numberOfTrips,
    };
  }

  @override
  String toString() {
    return 'Company(id: $id, companyId: $companyId, name: $name, numberOfRatings: $numberOfRatings, averageRating: $averageRating, numberOfTrips: $numberOfTrips)';
  }
}