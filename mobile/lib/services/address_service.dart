import '../models/user_address.dart';
import 'api_client.dart';

class AddressService {
  final ApiClient _apiClient = ApiClient();

  Future<List<UserAddress>> getAddresses() async {
    final response = await _apiClient.dio.get('/user-addresses');
    if (response.data['success'] == true) {
      final List data = response.data['data'];
      return data.map((json) => UserAddress.fromJson(json)).toList();
    }
    throw Exception(response.data['error']?['message'] ?? 'Failed to load addresses');
  }

  Future<UserAddress> addAddress(String addressText, bool isDefault) async {
    final response = await _apiClient.dio.post(
      '/user-addresses',
      data: {
        'addressText': addressText,
        'isDefault': isDefault,
      },
    );
    if (response.data['success'] == true) {
      return UserAddress.fromJson(response.data['data']);
    }
    throw Exception(response.data['error']?['message'] ?? 'Failed to add address');
  }

  Future<UserAddress> updateAddress(String id, String addressText, bool isDefault) async {
    final response = await _apiClient.dio.put(
      '/user-addresses/$id',
      data: {
        'addressText': addressText,
        'isDefault': isDefault,
      },
    );
    if (response.data['success'] == true) {
      return UserAddress.fromJson(response.data['data']);
    }
    throw Exception(response.data['error']?['message'] ?? 'Failed to update address');
  }

  Future<void> deleteAddress(String id) async {
    final response = await _apiClient.dio.delete('/user-addresses/$id');
    if (response.data['success'] != true) {
      throw Exception(response.data['error']?['message'] ?? 'Failed to delete address');
    }
  }

  Future<UserAddress> setDefaultAddress(String id) async {
    final response = await _apiClient.dio.post('/user-addresses/$id/default');
    if (response.data['success'] == true) {
      return UserAddress.fromJson(response.data['data']);
    }
    throw Exception(response.data['error']?['message'] ?? 'Failed to set default address');
  }
}
