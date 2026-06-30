import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  static const String _key = 'language_code';
  Locale _locale = const Locale('ru');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadFromPrefs();
  }

  void setLocale(Locale locale) async {
    if (!['ru', 'en'].contains(locale.languageCode)) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }

  void _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_key) ?? 'ru';
    _locale = Locale(languageCode);
    notifyListeners();
  }
}
