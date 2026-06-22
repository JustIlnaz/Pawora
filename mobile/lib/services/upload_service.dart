import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'api_client.dart';

class UploadService {
  final ApiClient _apiClient = ApiClient();

  Future<String> uploadImage(XFile file) async {
    final fileName = file.path.split('/').last.split('\\').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    final response = await _apiClient.dio.post(
      '/upload',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    if (response.data['success'] == true) {
      return response.data['data'] as String;
    } else {
      throw Exception(response.data['error']?['message'] ?? 'Загрузка файла не удалась');
    }
  }
}
