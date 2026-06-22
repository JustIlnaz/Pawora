import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../utils/error_handler.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.role?.toLowerCase() == 'admin';
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> tryAutoLogin() async {
    _user = await _storageService.getUser();
    final token = await _storageService.getAccessToken();
    if (_user != null && token != null) {
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final response = await _authService.login(email, password);
      await _storageService.saveTokens(response.accessToken, response.refreshToken);
      await _storageService.saveUser(response.user);
      _user = response.user;
    } catch (e) {
      _error = ErrorHandler.getFriendlyErrorMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String email, String password, String fullName, String? phone, String address) async {
    _setLoading(true);
    try {
      final response = await _authService.register(email, password, fullName, phone, address);
      await _storageService.saveTokens(response.accessToken, response.refreshToken);
      await _storageService.saveUser(response.user);
      _user = response.user;
    } catch (e) {
      _error = ErrorHandler.getFriendlyErrorMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      final token = await _storageService.getRefreshToken();
      if (token != null) {
        await _authService.logout(token);
      }
    } catch (_) {
      // Ignore
    } finally {
      await _storageService.clearTokens();
      _user = null;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _error = null;
    notifyListeners();
  }
}
