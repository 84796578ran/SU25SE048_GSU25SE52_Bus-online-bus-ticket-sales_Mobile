class Passenger {
  final String ticketId;
  final String customerFullName;

  Passenger({
    required this.ticketId,
    required this.customerFullName,
  });

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      ticketId: json['ticketId'] as String,
      customerFullName: json['customerFullName'] as String,
    );
  }
}