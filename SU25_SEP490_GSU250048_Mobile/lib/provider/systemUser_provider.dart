// lib/provider/system_user_provider.dart
import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/system_user_service.dart';
import 'dart:convert';

class SystemUserProvider with ChangeNotifier {
  String? _token;
  int? _systemUserId;
  String? _userName;
  String? _role;
  bool _isLoading = true;

  bool get isLoading => _isLoading;
  String? get token => _token;
  int? get systemUserId => _systemUserId;
  String? get userName => _userName;
  String? get role => _role;
  bool get isLoggedIn => _token != null;

  Future<void> login(String token) async {
    _token = token;
    Map<String, dynamic> payload = Jwt.parseJwt(token);

    final idStr = payload["nameid"]?.toString();
    if (idStr != null) {
      _systemUserId = int.tryParse(idStr.toString());
      print('SystemUserId from token: $_systemUserId');
    } else {
      print('Không tìm thấy SystemUserId trong token');
    }
    _userName = payload["unique_name"]?.toString();
    _role = payload["role"]?.toString();
    await SystemUserService.saveToken(token);
    _systemUserId = await SystemUserService.getSystemUserId();
    notifyListeners();
  }

  Future<void> loadToken() async {
    _token = await SystemUserService.getToken();
    _systemUserId = await SystemUserService.getSystemUserId();

    if (_token != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(_token!);
      _userName = payload["unique_name"]?.toString();
      _role = payload["role"]?.toString();
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _systemUserId = null;
    _userName = null;
    _role = null;
    await SystemUserService.clearToken();
    notifyListeners();
  }
}