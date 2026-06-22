import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'storage_service.dart';
import '../main.dart';
import '../providers/auth_provider.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio dio;
  final StorageService _storageService = StorageService();

  factory ApiClient() {
    return _instance;
  }

  static String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return 'http://10.0.2.2:5000$path';
  }

  void _handleLogoutAndRedirect() {
    Future.microtask(() {
      final context = PaworaApp.navigatorKey.currentContext;
      if (context != null && context.mounted) {
        Provider.of<AuthProvider>(context, listen: false).logout();
        Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
      }
    });
  }

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: 'http://10.0.2.2:5000/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storageService.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          final refreshToken = await _storageService.getRefreshToken();
          if (refreshToken != null) {
            try {
              // Create a new Dio instance to avoid interceptor loop
              final refreshDio = Dio();
              final response = await refreshDio.post(
                'http://10.0.2.2:5000/api/auth/refresh',
                data: {'refreshToken': refreshToken},
              );

              final newAccessToken = response.data['accessToken'];
              final newRefreshToken = response.data['refreshToken'];

              await _storageService.saveTokens(newAccessToken, newRefreshToken);

              e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              
              // Retry the failed request
              final retryResponse = await dio.fetch(e.requestOptions);
              return handler.resolve(retryResponse);
            } catch (refreshError) {
              await _storageService.clearTokens();
              _handleLogoutAndRedirect();
              return handler.next(e);
            }
          } else {
            await _storageService.clearTokens();
            _handleLogoutAndRedirect();
          }
        }
        return handler.next(e);
      },
    ));
  }
}
