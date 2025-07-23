import 'package:flutter/material.dart';
import 'package:mobile/services/author_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _avatarUrl;
  String? get token => _token;
  String? get avatarUrl => _avatarUrl;
  bool get isLoggedIn => _token != null;

  Future<void> loadToken() async {
    _token = await AuthService.getToken();
    await _loadAvatar();
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
  Future<void> _loadAvatar() async{
    final user = FirebaseAuth.instance.currentUser;
    _avatarUrl = user?.photoURL;
  }
  Future<void> updateAvatar(String url) async {
    _avatarUrl = url;
    final user = FirebaseAuth.instance.currentUser;
    await user?.updatePhotoURL(url);
    notifyListeners();
  }
}
