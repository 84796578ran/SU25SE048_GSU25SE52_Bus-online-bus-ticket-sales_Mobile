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
      id: json['id'] as int,
      ticketId: json['ticketId'] as String,
      tripId: json['tripId'] as String,
      reservationId: json['reservationId'] as int,
      customerName: json['customerName'] as String,
      seatId: json['seatId'] as String,
      price: (json['price'] as num).toDouble(),
      createDate: DateTime.parse(json['createDate'] as String),
      fromTripStation: json['fromTripStation'] as String,
      toTripStation: json['toTripStation'] as String,
      timeStart: DateTime.parse(json['timeStart'] as String),
      timeEnd: DateTime.parse(json['timeEnd'] as String),
      qrCodeUrl: json['qrCodeUrl'] as String,
      companyName: json['companyName'] as String,
      status: json['status'] as int,
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
