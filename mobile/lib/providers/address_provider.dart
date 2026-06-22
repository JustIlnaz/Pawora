import 'package:flutter/material.dart';
import '../models/user_address.dart';
import '../services/address_service.dart';
import '../utils/error_handler.dart';

class AddressProvider with ChangeNotifier {
  final AddressService _addressService = AddressService();
  List<UserAddress> _addresses = [];
  bool _isLoading = false;
  String? _error;

  List<UserAddress> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  UserAddress? get defaultAddress {
    try {
      return _addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  Future<void> fetchAddresses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _addresses = await _addressService.getAddresses();
    } catch (e) {
      _error = ErrorHandler.getFriendlyErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAddress(String addressText, bool isDefault) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newAddress = await _addressService.addAddress(addressText, isDefault);
      if (newAddress.isDefault) {
        _addresses = _addresses.map((a) => UserAddress(id: a.id, addressText: a.addressText, isDefault: false)).toList();
      }
      _addresses.add(newAddress);
      _sortAddresses();
      return true;
    } catch (e) {
      _error = ErrorHandler.getFriendlyErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAddress(String id, String addressText, bool isDefault) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _addressService.updateAddress(id, addressText, isDefault);
      if (updated.isDefault) {
        _addresses = _addresses.map((a) => a.id == id ? updated : UserAddress(id: a.id, addressText: a.addressText, isDefault: false)).toList();
      } else {
        _addresses = _addresses.map((a) => a.id == id ? updated : a).toList();
      }
      _sortAddresses();
      return true;
    } catch (e) {
      _error = ErrorHandler.getFriendlyErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAddress(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final wasDefault = _addresses.firstWhere((a) => a.id == id).isDefault;
      await _addressService.deleteAddress(id);
      _addresses.removeWhere((a) => a.id == id);
      if (wasDefault && _addresses.isNotEmpty) {
        await fetchAddresses();
      }
      return true;
    } catch (e) {
      _error = ErrorHandler.getFriendlyErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setDefaultAddress(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _addressService.setDefaultAddress(id);
      _addresses = _addresses.map((a) => a.id == id ? updated : UserAddress(id: a.id, addressText: a.addressText, isDefault: false)).toList();
      _sortAddresses();
      return true;
    } catch (e) {
      _error = ErrorHandler.getFriendlyErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _sortAddresses() {
    _addresses.sort((a, b) {
      if (a.isDefault && !b.isDefault) return -1;
      if (!a.isDefault && b.isDefault) return 1;
      return 0;
    });
  }

  void clearAddresses() {
    _addresses = [];
    _error = null;
    notifyListeners();
  }
}
