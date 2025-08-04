import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer.dart';
import '../services/author_service.dart';
import 'dart:convert'; // Đảm bảo import thư viện này

class AuthProvider with ChangeNotifier {
  String? _token;
  int? _customerId;
  String? _userName;
  String? _phone;
  Customer? _customer;

  String? get token => _token;
  int? get customerId => _customerId;
  String? get userName => _userName;
  String? get phone => _phone;

  bool get isLoggedIn => _token != null;
  Customer? get customer => _customer;

  Future<void> login(String token) async {
    _token = token;

    Map<String, dynamic> payload = Jwt.parseJwt(token);
    final idStr = payload["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"];
    if (idStr != null) {
      _customerId = int.tryParse(idStr.toString());
      print('customerId from token: $_customerId');
    } else {
      print(' Không tìm thấy customerId trong token');
    }

    _userName = payload["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"];
    _phone = payload["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"];

    await AuthService.saveToken(token);
    notifyListeners();
  }

  Future<void> loadToken() async {
    _token = await AuthService.getToken();
     _customerId = await AuthService.getCustomerId();
    if (_token != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(_token!);
      _userName = payload["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"];
      _phone = payload["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"];
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _customerId = null;
    _userName = null;
    _phone = null;
    await AuthService.clearToken();
    notifyListeners();
  }
}