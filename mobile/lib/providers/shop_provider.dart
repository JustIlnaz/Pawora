import 'package:flutter/material.dart';
import '../models/shop.dart';
import '../services/shop_service.dart';
import '../utils/error_handler.dart';

class ShopProvider with ChangeNotifier {
  final ShopService _shopService = ShopService();

  List<Shop> _shops = [];
  List<Shop> _nearbyShops = [];
  bool _isLoading = false;
  String? _error;

  List<Shop> get shops => _shops;
  List<Shop> get nearbyShops => _nearbyShops;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchShops() async {
    _setLoading(true);
    try {
      _shops = await _shopService.getShops();
    } catch (e) {
      _error = ErrorHandler.getFriendlyErrorMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchNearbyShops(double lat, double lng, double radius) async {
    _setLoading(true);
    try {
      _nearbyShops = await _shopService.getNearbyShops(lat, lng, radius);
    } catch (e) {
      _error = ErrorHandler.getFriendlyErrorMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _error = null;
    notifyListeners();
  }
}
