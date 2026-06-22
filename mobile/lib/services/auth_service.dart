import 'api_client.dart';
import '../models/auth_response.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<AuthResponse> register(String email, String password, String fullName, String? phone, String address) async {
    final response = await _apiClient.dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'fullName': fullName,
      'phone': phone,
      'address': address,
    });
    return AuthResponse.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await _apiClient.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return AuthResponse.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<AuthResponse> refreshToken(String token) async {
    final response = await _apiClient.dio.post('/auth/refresh', data: {
      'refreshToken': token,
    });
    return AuthResponse.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> logout(String token) async {
    await _apiClient.dio.post('/auth/logout', data: {
      'refreshToken': token,
    });
  }
}
