import 'package:flutter/cupertino.dart';

class TripProvider with ChangeNotifier {
  int? _currentTripId;

  int? get currentTripId => _currentTripId;

  void setTripId(int id) {
    _currentTripId = id;
    notifyListeners();
  }
}
