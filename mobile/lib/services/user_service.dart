import 'api_client.dart';
import '../models/user.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  Future<User> getProfile() async {
    final response = await _apiClient.dio.get('/users/profile');
    return User.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<User> updateProfile(String fullName, String? phone, String? avatarUrl) async {
    final response = await _apiClient.dio.put('/users/profile', data: {
      'fullName': fullName,
      'phone': phone,
      'avatarUrl': avatarUrl,
    });
    return User.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
