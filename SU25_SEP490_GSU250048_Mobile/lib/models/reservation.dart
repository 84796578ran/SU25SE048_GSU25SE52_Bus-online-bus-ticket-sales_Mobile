class Reservation {
  final int customerId;
  final bool isReturn;
  final List<TripSeats> tripSeats;
  final List<TripSeats>? returnTripSeats;

  Reservation({
    required this.customerId,
    required this.isReturn,
    required this.tripSeats,
    this.returnTripSeats,
  });

  // Constructor factory để tạo đối tượng từ JSON
  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      customerId: json['customerId'] as int,
      isReturn: json['isReturn'] as bool,
      tripSeats: (json['tripSeats'] as List<dynamic>)
          .map((e) => TripSeats.fromJson(e as Map<String, dynamic>))
          .toList(),
      returnTripSeats: (json['returnTripSeats'] as List<dynamic>?)
          ?.map((e) => TripSeats.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Phương thức để chuyển đổi đối tượng Dart thành JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'customerId': customerId,
      'isReturn': isReturn,
      'tripSeats': tripSeats.map((e) => e.toJson()).toList(),
    };
    if (returnTripSeats != null) {
      data['returnTripSeats'] = returnTripSeats!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

// Lớp TripSeats cần được định nghĩa riêng
class TripSeats {
  final int tripId;
  final int fromStationId;
  final int toStationId;
  final List<int> seatIds;

  TripSeats({
    required this.tripId,
    required this.fromStationId,
    required this.toStationId,
    required this.seatIds,
  });

  // Constructor factory để tạo đối tượng từ JSON
  factory TripSeats.fromJson(Map<String, dynamic> json) {
    return TripSeats(
      tripId: json['tripId'] as int,
      fromStationId: json['fromStationId'] as int,
      toStationId: json['toStationId'] as int,
      seatIds: (json['seatIds'] as List<dynamic>).map((e) => e as int).toList(),
    );
  }

  // Phương thức để chuyển đổi đối tượng Dart thành JSON
  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'fromStationId': fromStationId,
      'toStationId': toStationId,
      'seatIds': seatIds,
    };
  }
}