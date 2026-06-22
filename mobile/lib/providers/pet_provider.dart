import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/pet.dart';
import '../services/pet_service.dart';
import '../services/upload_service.dart';
import '../utils/error_handler.dart';

class PetProvider with ChangeNotifier {
  final PetService _petService = PetService();
  final UploadService _uploadService = UploadService();

  List<Pet> _pets = [];
  bool _isLoading = false;
  String? _error;

  List<Pet> get pets => _pets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPets() async {
    _setLoading(true);
    try {
      _pets = await _petService.getPets();
    } catch (e) {
      _error = ErrorHandler.getFriendlyErrorMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addPet(String name, String species, String? breed, XFile? imageFile, String? birthDate) async {
    _setLoading(true);
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadService.uploadImage(imageFile);
      } else {
        imageUrl = 'https://images.unsplash.com/photo-1543466835-00a7907e9de1';
      }
      final pet = await _petService.createPet(name, species, breed, imageUrl, birthDate);
      _pets.add(pet);
    } catch (e) {
      _error = ErrorHandler.getFriendlyErrorMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePet(String id, String name, String species, String? breed, XFile? imageFile, String? birthDate) async {
    _setLoading(true);
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadService.uploadImage(imageFile);
      } else {
        imageUrl = _pets.firstWhere((p) => p.id == id).imageUrl;
      }
      final pet = await _petService.updatePet(id, name, species, breed, imageUrl, birthDate);
      final index = _pets.indexWhere((p) => p.id == id);
      if (index != -1) {
        _pets[index] = pet;
      }
    } catch (e) {
      _error = ErrorHandler.getFriendlyErrorMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deletePet(String id) async {
    _setLoading(true);
    try {
      await _petService.deletePet(id);
      _pets.removeWhere((pet) => pet.id == id);
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
