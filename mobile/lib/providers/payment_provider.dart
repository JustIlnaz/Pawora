import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/payment_card.dart';

class PaymentProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  List<PaymentCard> _cards = [];
  bool _isLoading = false;

  List<PaymentCard> get cards => _cards;
  bool get isLoading => _isLoading;

  String _userId = 'guest';

  void updateUser(String? userId) {
    final newId = userId ?? 'guest';
    if (_userId != newId) {
      _userId = newId;
      _cards = [];
    }
  }

  String get _storageKey => 'saved_cards_$_userId';

  Future<void> loadCards() async {
    _isLoading = true;
    notifyListeners();
    try {
      final String? cardsJson = await _storage.read(key: _storageKey);
      if (cardsJson != null) {
        final List<dynamic> decoded = jsonDecode(cardsJson);
        _cards = decoded.map((e) => PaymentCard.fromJson(e)).toList();
      } else {
        _cards = [];
      }
    } catch (e) {
      debugPrint('Error loading cards: $e');
      _cards = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCard(PaymentCard card) async {
    if (_cards.isEmpty || card.isDefault) {
      if (card.isDefault) {
        _cards = _cards.map((c) => PaymentCard(
          id: c.id, number: c.number, expiryDate: c.expiryDate, cvv: c.cvv, cardHolderName: c.cardHolderName, isDefault: false
        )).toList();
      }
    }
    _cards.add(card);
    if (_cards.length == 1) {
       _cards[0] = PaymentCard(
          id: card.id, number: card.number, expiryDate: card.expiryDate, cvv: card.cvv, cardHolderName: card.cardHolderName, isDefault: true
       );
    }
    await _saveCards();
    notifyListeners();
  }

  Future<void> removeCard(String id) async {
    _cards.removeWhere((c) => c.id == id);
    if (_cards.isNotEmpty && !_cards.any((c) => c.isDefault)) {
      final c = _cards[0];
      _cards[0] = PaymentCard(id: c.id, number: c.number, expiryDate: c.expiryDate, cvv: c.cvv, cardHolderName: c.cardHolderName, isDefault: true);
    }
    await _saveCards();
    notifyListeners();
  }

  Future<void> setDefaultCard(String id) async {
    _cards = _cards.map((c) => PaymentCard(
      id: c.id, number: c.number, expiryDate: c.expiryDate, cvv: c.cvv, cardHolderName: c.cardHolderName, isDefault: c.id == id
    )).toList();
    await _saveCards();
    notifyListeners();
  }

  Future<void> _saveCards() async {
    final String encoded = jsonEncode(_cards.map((c) => c.toJson()).toList());
    await _storage.write(key: _storageKey, value: encoded);
  }
}
