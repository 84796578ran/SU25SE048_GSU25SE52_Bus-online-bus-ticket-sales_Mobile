class Ticket {
  final int id;
  final String ticketId;
  final String? customerId;
  final String? customerName;
  final String? seatId;
  final double price;
  final DateTime createDate;
  final String? fromTripStation;
  final String? toTripStation;
  final int status;

  Ticket({
    required this.id, // Đã thêm id vào constructor, có thể null
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
      id: json['id'] as int, // Đã thêm id và ép kiểu thành int?
      ticketId: json['ticketId'] as String,
      customerId: json['customerId']?.toString(),
      customerName: json['customerName']?.toString(),
      seatId: json['seatId']?.toString(),
      price: (json['price'] as num).toDouble(),
      createDate: DateTime.parse(json['createDate'] as String),
      fromTripStation: json['fromTripStation'] as String?,
      toTripStation: json['toTripStation'] as String?,
      status: json['status'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Đã thêm id vào đây
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