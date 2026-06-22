import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/upload_service.dart';
import '../services/storage_service.dart';
import '../utils/error_handler.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  final UploadService _uploadService = UploadService();
  final StorageService _storageService = StorageService();

  User? _profile;
  bool _isLoading = false;
  String? _error;

  User? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile() async {
    _setLoading(true);
    try {
      _profile = await _userService.getProfile();
    } catch (e) {
      _error = ErrorHandler.getFriendlyErrorMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile(String fullName, String? phone, XFile? imageFile) async {
    _setLoading(true);
    try {
      String? avatarUrl;
      if (imageFile != null) {
        avatarUrl = await _uploadService.uploadImage(imageFile);
      } else {
        avatarUrl = _profile?.avatarUrl ?? (await _storageService.getUser())?.avatarUrl;
      }
      _profile = await _userService.updateProfile(fullName, phone, avatarUrl);
      await _storageService.saveUser(_profile!);
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
