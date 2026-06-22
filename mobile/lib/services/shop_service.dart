import 'api_client.dart';
import '../models/shop.dart';

class ShopService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Shop>> getShops() async {
    final response = await _apiClient.dio.get('/shops');
    return (response.data['data'] as List).map((json) => Shop.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Shop> getShopById(String id) async {
    final response = await _apiClient.dio.get('/shops/$id');
    return Shop.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<Shop>> getNearbyShops(double lat, double lng, double radius) async {
    final response = await _apiClient.dio.get('/shops/nearby', queryParameters: {
      'lat': lat,
      'lng': lng,
      'radius': radius,
    });
    return (response.data['data'] as List).map((json) => Shop.fromJson(json as Map<String, dynamic>)).toList();
  }
}
