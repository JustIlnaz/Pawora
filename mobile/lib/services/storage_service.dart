import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();
  
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userKey = 'user_data';

  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: _accessTokenKey, value: access);
    await _storage.write(key: _refreshTokenKey, value: refresh);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userKey);
  }

  Future<void> saveUser(User user) async {
    final jsonStr = jsonEncode(user.toJson());
    await _storage.write(key: _userKey, value: jsonStr);
  }

  Future<User?> getUser() async {
    final jsonStr = await _storage.read(key: _userKey);
    if (jsonStr != null) {
      return User.fromJson(jsonDecode(jsonStr));
    }
    return null;
  }

  Future<void> saveFavorites(List<String> productIds) async {
    await _storage.write(key: 'favorite_products', value: jsonEncode(productIds));
  }

  Future<List<String>> getFavorites() async {
    final jsonStr = await _storage.read(key: 'favorite_products');
    if (jsonStr != null) {
      final decoded = jsonDecode(jsonStr);
      return List<String>.from(decoded);
    }
    return [];
  }
}
