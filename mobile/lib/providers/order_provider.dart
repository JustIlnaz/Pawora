import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../utils/error_handler.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchOrders() async {
    _setLoading(true);
    try {
      _orders = await _orderService.getOrders();
    } catch (e) {
      _error = ErrorHandler.getFriendlyErrorMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createOrder(String? shopId, String? address, List<Map<String, dynamic>> items) async {
    _setLoading(true);
    try {
      final order = await _orderService.createOrder(shopId, address, items);
      _orders.insert(0, order);
    } catch (e) {
      _error = ErrorHandler.getFriendlyErrorMessage(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _error = null;
    notifyListeners();
  }

  Future<void> updateOrderStatus(String id, String status) async {
    _setLoading(true);
    try {
      final updatedOrder = await _orderService.updateOrderStatus(id, status);
      final index = _orders.indexWhere((o) => o.id == id);
      if (index != -1) {
        _orders[index] = updatedOrder;
        notifyListeners();
      }
    } catch (e) {
      _error = ErrorHandler.getFriendlyErrorMessage(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
