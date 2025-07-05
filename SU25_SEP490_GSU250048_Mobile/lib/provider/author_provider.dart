import 'package:flutter/material.dart';
import 'package:mobile/services/author_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;

  String? get token => _token;

  bool get isLoggedIn => _token != null;

  Future<void> loadToken() async {
    _token = await AuthService.getToken();
    notifyListeners();
  }

  Future<void> login(String token) async {
    _token = token;
    await AuthService.saveToken(token);
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    await AuthService.clearToken();
    notifyListeners();
  }
}
