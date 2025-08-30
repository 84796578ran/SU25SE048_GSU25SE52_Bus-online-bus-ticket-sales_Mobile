enum TicketStatus {
  paid(0),
  onTrip(1),
  canceled(2),
  pending(3),
  unpaid(4),
  completed(5),
  unknown(99); // Thêm một trạng thái cho giá trị không xác định

  const TicketStatus(this.value);
  final int value;

  // Phương thức để lấy giá trị enum từ một số nguyên
  static TicketStatus fromInt(int? status) {
    if (status == null) return unknown;
    return TicketStatus.values.firstWhere(
          (e) => e.value == status,
      orElse: () => unknown,
    );
  }

  // Getter để lấy chuỗi mô tả
  String get name {
    switch (this) {
      case TicketStatus.paid:
        return 'Đã thanh toán';
      case TicketStatus.onTrip:
        return 'Đang thực hiện chuyến đi';
      case TicketStatus.canceled:
        return 'Đã hủy';
      case TicketStatus.pending:
        return 'Đang chờ xử lý';
      case TicketStatus.unpaid:
        return 'Chưa thanh toán';
      case TicketStatus.completed:
        return 'Đã hoàn thành chuyến đi';
      case TicketStatus.unknown:
        return 'Không xác định';
    }
  }
}