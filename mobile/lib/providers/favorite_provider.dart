import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class FavoriteProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<String> _favoriteIds = [];
  String _userId = 'guest';

  List<String> get favoriteIds => _favoriteIds;

  void updateUser(String? userId) {
    final newId = userId ?? 'guest';
    if (_userId != newId) {
      _userId = newId;
      _favoriteIds = [];
      loadFavorites();
    }
  }

  FavoriteProvider() {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    _favoriteIds = await _storageService.getFavorites(_userId);
    notifyListeners();
  }

  bool isFavorite(String productId) {
    return _favoriteIds.contains(productId);
  }

  Future<void> toggleFavorite(String productId) async {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    await _storageService.saveFavorites(_userId, _favoriteIds);
    notifyListeners();
  }
}
