class Ticket {
  final int id;
  final String ticketId;
  final String tripId;
  final int reservationId;
  final String customerName;
  final String seatId;
  final double price;
  final DateTime createDate;
  final String fromTripStation;
  final String toTripStation;
  final DateTime timeStart;
  final DateTime timeEnd;
  final String qrCodeUrl;
  final String companyName;
  final int status;


  Ticket({
    required this.id,
    required this.ticketId,
    required this.tripId,
    required this.reservationId,
    required this.customerName,
    required this.seatId,
    required this.price,
    required this.createDate,
    required this.fromTripStation,
    required this.toTripStation,
    required this.timeStart,
    required this.timeEnd,
    required this.qrCodeUrl,
    required this.companyName,
    required this.status,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] ?? 0,
      ticketId: json['ticketId'] ?? '',
      tripId: json['tripId']?.toString() ?? '',
      reservationId: json['reservationId'] ?? 0,
      customerName: json['customerName'] ?? '',
      seatId: json['seatId'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      createDate: DateTime.tryParse(json['createDate'] ?? '') ?? DateTime.now(),
      fromTripStation: json['fromTripStation'] ?? '',
      toTripStation: json['toTripStation'] ?? '',
      timeStart: DateTime.tryParse(json['timeStart'] ?? '') ?? DateTime.now(),
      timeEnd: DateTime.tryParse(json['timeEnd'] ?? '') ?? DateTime.now(),
      qrCodeUrl: json['qrCodeUrl'] ?? '',
      companyName: json['companyName'] ?? '',
      status: json['status'] ?? -1,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketId': ticketId,
      'tripId': tripId,
      'reservationId': reservationId,
      'customerName': customerName,
      'seatId': seatId,
      'price': price,
      'createDate': createDate.toIso8601String(),
      'fromTripStation': fromTripStation,
      'toTripStation': toTripStation,
      'timeStart': timeStart.toIso8601String(),
      'timeEnd': timeEnd.toIso8601String(),
      'qrCodeUrl': qrCodeUrl,
      'companyName': companyName,
      'status': status,
    };
  }
}
