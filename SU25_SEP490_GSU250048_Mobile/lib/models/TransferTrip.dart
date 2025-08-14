import 'package:mobile/models/trip.dart';

class TransferTrip {
  final Trip firstTrip;
  final Trip? secondTrip;
  final double price;

  TransferTrip({
    required this.firstTrip,
    this.secondTrip,
  }) :
        price = firstTrip.price + (secondTrip?.price ?? 0.0);

  factory TransferTrip.fromJson(Map<String, dynamic> json) {
    final Trip firstTrip = Trip.fromJson(json['firstTrip'] as Map<String, dynamic>);

    Trip? secondTrip;
    if (json.containsKey('secondTrip') && json['secondTrip'] != null) {
      secondTrip = Trip.fromJson(json['secondTrip'] as Map<String, dynamic>);
    }
    return TransferTrip(
      firstTrip: firstTrip,
      secondTrip: secondTrip,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'firstTrip': firstTrip.toJson(),
      'secondTrip': secondTrip?.toJson(),
    };
  }
}