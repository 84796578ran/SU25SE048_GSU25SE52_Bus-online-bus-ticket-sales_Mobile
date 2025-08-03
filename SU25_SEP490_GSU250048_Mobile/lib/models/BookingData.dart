import 'package:mobile/models/seat.dart';
import 'package:mobile/models/station.dart';

class BookingData {
  final dynamic tripOrTransferTrip;
  final Seat? selectedFirstSeat;
  final Seat? selectedSecondSeat;
  final Map<int, Station> stations;
  BookingData({
    required this.tripOrTransferTrip,
    this.selectedFirstSeat,
    this.selectedSecondSeat,
    required this.stations,
  });
}