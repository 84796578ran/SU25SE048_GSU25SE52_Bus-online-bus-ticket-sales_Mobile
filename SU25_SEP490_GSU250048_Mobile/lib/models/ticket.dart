class Ticket {
  final String ticketId;
  final String? customerId;
  final String? customerName;
  final int seatId;
  final double price;
  final DateTime createDate;
  final String? fromTripStation; // Đã cập nhật thành String
  final String? toTripStation; // Đã cập nhật thành String
  final int status;

  Ticket({
    required this.ticketId,
    required this.customerId,
    required this.customerName,
    required this.seatId,
    required this.price,
    required this.createDate,
    this.fromTripStation,
    this.toTripStation,
    required this.status,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      ticketId: json['ticketId'] as String,
      customerId: json['customerId']?.toString(),
      customerName: json['customerName']?.toString(),
      seatId: json['seatId'] as int,
      price: (json['price'] as num).toDouble(),
      createDate: DateTime.parse(json['createDate'] as String),
      fromTripStation: json['fromTripStation'] as String?,
      toTripStation: json['toTripStation'] as String?,
      status: json['status'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketId': ticketId,
      'customerId': customerId,
      'customerName': customerName,
      'seatId': seatId,
      'price': price,
      'createDate': createDate.toIso8601String(),
      'fromTripStation': fromTripStation,
      'toTripStation': toTripStation,
      'status': status,
    };
  }
}