enum TripStatus {
  scheduled(0),
  active(1),
  completed(2),
  cancelled(3),
  unknown(-1);
  final int value;
  const TripStatus(this.value);
  static TripStatus fromInt(int value) {
    for (var status in TripStatus.values) {
      if (status.value == value) {
        return status;
      }
    }
    return TripStatus.unknown;
  }
  String get displayName {
    switch (this) {
      case TripStatus.scheduled:
        return 'Scheduled';
      case TripStatus.active:
        return 'Đang hoạt động';
      case TripStatus.completed:
        return 'Hoàn tất';
      case TripStatus.cancelled:
        return 'xóa';
      case TripStatus.unknown:
      default:
        return 'Không tìm thấy';
    }
  }
}