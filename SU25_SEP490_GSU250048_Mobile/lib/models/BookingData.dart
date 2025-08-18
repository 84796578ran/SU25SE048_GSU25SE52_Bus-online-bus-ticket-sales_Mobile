// import 'package:mobile/models/seat.dart';
// import 'package:mobile/models/station.dart';
//
// class BookingData {
//   // Chuyến đi
//   final dynamic tripOrTransferTrip;
//   final Seat? selectedFirstSeat; // ghế chặng 1 (hoặc ghế của trip trực tiếp)
//   final Seat? selectedSecondSeat; // ghế chặng 2 nếu trung chuyển
//
//   // Chuyến về (khứ hồi)
//   final dynamic returnTripOrTransferTrip;
//   final Seat? returnSelectedFirstSeat;
//   final Seat? returnSelectedSecondSeat;
//
//   final bool isRoundTrip;
//   final Map<int, Station> stations;
//
//   BookingData({
//     required this.tripOrTransferTrip,
//     this.selectedFirstSeat,
//     this.selectedSecondSeat,
//     this.returnTripOrTransferTrip,
//     this.returnSelectedFirstSeat,
//     this.returnSelectedSecondSeat,
//     this.isRoundTrip = false,
//     required this.stations,
//   });
// }
import 'package:mobile/models/seat.dart';
import 'package:mobile/models/station.dart';

class BookingData {
  // Chuyến đi
  final dynamic tripOrTransferTrip;
  final List<Seat> selectedFirstSeats; // danh sách ghế chặng 1 (hoặc ghế của trip trực tiếp)
  final List<Seat> selectedSecondSeats; // danh sách ghế chặng 2 nếu trung chuyển

  // Chuyến về (khứ hồi)
  final dynamic returnTripOrTransferTrip;
  final List<Seat> returnSelectedFirstSeats;
  final List<Seat> returnSelectedSecondSeats;
  final bool isRoundTrip;
  final Map<int, Station> stations;

  BookingData({
    required this.tripOrTransferTrip,
    required this.selectedFirstSeats,
    this.selectedSecondSeats = const [],
    this.returnTripOrTransferTrip,
    this.returnSelectedFirstSeats = const [],
    this.returnSelectedSecondSeats = const [],
    this.isRoundTrip = false,
    required this.stations,
  });
}