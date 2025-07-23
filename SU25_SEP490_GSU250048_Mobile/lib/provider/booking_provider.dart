import 'package:flutter/cupertino.dart';

import '../models/reservation.dart';

class BookingProvider with ChangeNotifier{
  Reservation? _current;

  Reservation? get current => _current;

  void setReservation(Reservation r) {
    _current = r;
    notifyListeners();
  }

  void clear() {
    _current = null;
    notifyListeners();
  }
}