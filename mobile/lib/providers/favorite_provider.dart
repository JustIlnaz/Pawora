import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class FavoriteProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<String> _favoriteIds = [];

  List<String> get favoriteIds => _favoriteIds;

  FavoriteProvider() {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    _favoriteIds = await _storageService.getFavorites();
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
    await _storageService.saveFavorites(_favoriteIds);
    notifyListeners();
  }
}
