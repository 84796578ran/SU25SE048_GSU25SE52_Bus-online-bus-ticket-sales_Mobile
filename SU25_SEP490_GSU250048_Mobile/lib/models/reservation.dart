
class Reservation {
  final String id;
  final bool? isReturn;
  final DateTime startDate;
  final DateTime endDate;
  final String customerId;
  final int? totalNumber;
  final int? status;
  final bool isCancellable;

  Reservation({
    required this.id,
    this.isReturn,
    required this.startDate,
    required this.endDate,
    required this.customerId,
    this.totalNumber,
    this.status,
    this.isCancellable = true,
  });
  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as String,
      isReturn: json['isReturn'] as bool?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      customerId: json['customerId'] as String,
      totalNumber: json['totalNumber'] as int?,
      status: json['status'] as int?,
      isCancellable: json['isCancellable'] as bool? ?? true, // Default to true if not provided in JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isReturn': isReturn,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'customerId': customerId,
      'totalNumber': totalNumber,
      'status': status,
      'isCancellable': isCancellable,
    };
  }
}