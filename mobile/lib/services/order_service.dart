import 'api_client.dart';
import '../models/order.dart';

class OrderService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Order>> getOrders() async {
    final response = await _apiClient.dio.get('/orders');
    return (response.data['data'] as List).map((json) => Order.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Order> getOrderById(String id) async {
    final response = await _apiClient.dio.get('/orders/$id');
    return Order.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Order> createOrder(String? shopId, String? address, List<Map<String, dynamic>> items) async {
    final response = await _apiClient.dio.post('/orders', data: {
      'shopId': shopId,
      'address': address,
      'items': items,
    });
    return Order.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Order> updateOrderStatus(String id, String status) async {
    int statusEnumVal = 0;
    switch (status) {
      case 'New': statusEnumVal = 0; break;
      case 'InProgress': statusEnumVal = 1; break;
      case 'Delivered': statusEnumVal = 2; break;
      case 'Cancelled': statusEnumVal = 3; break;
    }
    
    final response = await _apiClient.dio.put('/orders/$id/status', data: {
      'status': statusEnumVal,
    });
    return Order.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
