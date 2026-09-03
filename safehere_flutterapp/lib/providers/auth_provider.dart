import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/secure_storage_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();
  final _userService = UserService();

  AuthStatus status = AuthStatus.unknown;
  AppUser? currentUser;
  String? lastError;

  Future<void> bootstrap() async {
    final token = await SecureStorageService.accessToken;
    if (token == null) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      currentUser = await _authService.me();
      status = AuthStatus.authenticated;
    } catch (_) {
      await SecureStorageService.clear();
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      lastError = null;
      await _authService.login(email: email, password: password);
      currentUser = await _authService.me();
      status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      lastError = apiErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String fullName, String email, String password) async {
    try {
      lastError = null;
      await _authService.register(fullName: fullName, email: email, password: password);
      currentUser = await _authService.me();
      status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      lastError = apiErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> patch) async {
    currentUser = await _userService.updateMe(patch);
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    currentUser = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
