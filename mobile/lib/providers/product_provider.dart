import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/product_service.dart';
import '../utils/error_handler.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  List<Product> get customerProducts => _products.where((p) => p.stock > 0).toList();
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProducts({String? categoryId, String? shopId, String? search}) async {
    _setLoading(true);
    try {
      _products = await _productService.getProducts(categoryId: categoryId, shopId: shopId, search: search);
    } catch (e) {
      _error = ErrorHandler.getFriendlyErrorMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchCategories() async {
    _setLoading(true);
    try {
      _categories = await _productService.getCategories();
    } catch (e) {
      _error = ErrorHandler.getFriendlyErrorMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchProducts(String query) async {
    _setLoading(true);
    try {
      _products = await _productService.getProducts(search: query);
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

  Future<void> createProduct(Map<String, dynamic> productData) async {
    _setLoading(true);
    try {
      final product = await _productService.createProduct(productData);
      _products.add(product);
    } catch (e) {
      _error = ErrorHandler.getFriendlyErrorMessage(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteProduct(String id) async {
    _setLoading(true);
    try {
      await _productService.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
    } catch (e) {
      _error = ErrorHandler.getFriendlyErrorMessage(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> productData) async {
    _setLoading(true);
    try {
      final updated = await _productService.updateProduct(id, productData);
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updated;
      }
    } catch (e) {
      _error = ErrorHandler.getFriendlyErrorMessage(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void decreaseStockLocally(String id, int quantity) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      final currentStock = _products[index].stock;
      final updatedStock = (currentStock - quantity) < 0 ? 0 : (currentStock - quantity);
      
      _products[index] = Product(
        id: _products[index].id,
        name: _products[index].name,
        description: _products[index].description,
        imageUrl: _products[index].imageUrl,
        shopName: _products[index].shopName,
        categoryName: _products[index].categoryName,
        price: _products[index].price,
        discountPrice: _products[index].discountPrice,
        shopId: _products[index].shopId,
        categoryId: _products[index].categoryId,
        stock: updatedStock,
        rating: _products[index].rating,
        reviewCount: _products[index].reviewCount,
      );
      notifyListeners();
    }
  }

  void increaseStockLocally(String id, int quantity) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      final currentStock = _products[index].stock;
      final updatedStock = currentStock + quantity;
      
      _products[index] = Product(
        id: _products[index].id,
        name: _products[index].name,
        description: _products[index].description,
        imageUrl: _products[index].imageUrl,
        shopName: _products[index].shopName,
        categoryName: _products[index].categoryName,
        price: _products[index].price,
        discountPrice: _products[index].discountPrice,
        shopId: _products[index].shopId,
        categoryId: _products[index].categoryId,
        stock: updatedStock,
        rating: _products[index].rating,
        reviewCount: _products[index].reviewCount,
      );
      notifyListeners();
    }
  }
}
