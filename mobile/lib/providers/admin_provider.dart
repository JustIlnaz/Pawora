import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/api_client.dart';
import '../utils/error_handler.dart';

class AdminProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  int _totalOrders = 0;
  double _totalRevenue = 0.0;
  int _totalProducts = 0;
  int _totalClients = 0;
  List<Order> _allOrders = [];
  bool _isLoading = false;
  String? _error;

  int get totalOrders => _totalOrders;
  double get totalRevenue => _totalRevenue;
  int get totalProducts => _totalProducts;
  int get totalClients => _totalClients;
  List<Order> get allOrders => _allOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStats() async {
    _setLoading(true);
    try {
      final response = await _apiClient.dio.get('/admin/dashboard/stats');
      final data = response.data['data'] as Map<String, dynamic>;
      
      _totalOrders = data['totalOrders'] as int;
      _totalRevenue = (data['totalRevenue'] as num).toDouble();
      _totalProducts = data['totalProducts'] as int;
      _totalClients = data['totalClients'] as int;
    } catch (e) {
      _error = ErrorHandler.getFriendlyErrorMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchOrders() async {
    _setLoading(true);
    try {
      final response = await _apiClient.dio.get('/orders/all');
      final list = response.data['data'] as List<dynamic>;
      _allOrders = list.map((json) => Order.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      _error = ErrorHandler.getFriendlyErrorMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    _setLoading(true);
    try {
      // Map string status to backend enum value
      int statusEnumVal = 0;
      switch (status) {
        case 'New': statusEnumVal = 0; break;
        case 'InProgress': statusEnumVal = 1; break;
        case 'Delivered': statusEnumVal = 2; break;
        case 'Cancelled': statusEnumVal = 3; break;
      }
      
      await _apiClient.dio.put('/orders/$orderId/status', data: {'status': statusEnumVal});
      
      // Update local state
      final index = _allOrders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        // Fetch full order again or update status in local list
        await fetchOrders();
      }
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
