import 'api_client.dart';
import '../models/pet.dart';

class PetService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Pet>> getPets() async {
    final response = await _apiClient.dio.get('/pets');
    return (response.data['data'] as List).map((json) => Pet.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Pet> createPet(String name, String species, String? breed, String? imageUrl, String? birthDate) async {
    final response = await _apiClient.dio.post('/pets', data: {
      'name': name,
      'species': species,
      'breed': breed,
      'imageUrl': imageUrl,
      'birthDate': birthDate,
    });
    return Pet.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Pet> updatePet(String id, String name, String species, String? breed, String? imageUrl, String? birthDate) async {
    final response = await _apiClient.dio.put('/pets/$id', data: {
      'name': name,
      'species': species,
      'breed': breed,
      'imageUrl': imageUrl,
      'birthDate': birthDate,
    });
    return Pet.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> deletePet(String id) async {
    await _apiClient.dio.delete('/pets/$id');
  }
}
