import 'package:mobile/widget/seat_widget.dart'; // Đây là nơi định nghĩa enum SeatStatus và các widget

class Seat {
  final int id;
  final String seatId;
  final bool isAvailable;
  final SeatStatus status;
  bool isSelected;

  Seat({
    required this.id,
    required this.seatId,
    required this.isAvailable,
    this.status = SeatStatus.available, // Khởi tạo với giá trị mặc định
    this.isSelected = false, // Khởi tạo với giá trị mặc định
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      id: json['id'] as int,
      seatId: json['seatId'] as String,
      isAvailable: json['isAvailable'] as bool,
      // Các trường status và isSelected sẽ sử dụng giá trị mặc định
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seatId': seatId,
      'isAvailable': isAvailable,
    };
  }

  @override
  String toString() {
    return 'Seat(id: $id, seatId: $seatId, isAvailable: $isAvailable, status: $status, isSelected: $isSelected)';
  }
}