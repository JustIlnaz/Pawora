import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'ru': {
      'settings': 'Настройки',
      'notifications': 'Уведомления',
      'notifications_sub': 'Получать обновления о заказах и предложениях',
      'dark_theme': 'Тёмная тема',
      'theme_enabled': 'Включена',
      'theme_disabled': 'Выключена',
      'language': 'Язык',
      'russian': 'Русский',
      'english': 'Английский',
      'about_pawora': 'О PAWORA',
      'privacy_policy': 'Политика конфиденциальности',
      'profile': 'Профиль',
      'my_pets': 'Мои питомцы',
      'add_pet': '+ Добавить',
      'no_pets': 'Питомцы пока не добавлены.',
      'admin_panel': 'Панель управления',
      'my_orders': 'Мои заказы',
      'favorites': 'Избранное',
      'delivery_addresses': 'Адреса доставки',
      'payment_methods': 'Способы оплаты',
      'help_support': 'Помощь и поддержка',
      'logout': 'Выйти из аккаунта',
      'logout_confirm_title': 'Выход из аккаунта',
      'logout_confirm_msg': 'Вы уверены, что хотите выйти из аккаунта?',
      'cancel': 'Отмена',
      'logout_btn': 'Выйти',
    },
    'en': {
      'settings': 'Settings',
      'notifications': 'Notifications',
      'notifications_sub': 'Receive updates about orders and offers',
      'dark_theme': 'Dark Theme',
      'theme_enabled': 'Enabled',
      'theme_disabled': 'Disabled',
      'language': 'Language',
      'russian': 'Russian',
      'english': 'English',
      'about_pawora': 'About PAWORA',
      'privacy_policy': 'Privacy Policy',
      'profile': 'Profile',
      'my_pets': 'My Pets',
      'add_pet': '+ Add',
      'no_pets': 'No pets added yet.',
      'admin_panel': 'Admin Dashboard',
      'my_orders': 'My Orders',
      'favorites': 'Favorites',
      'delivery_addresses': 'Delivery Addresses',
      'payment_methods': 'Payment Methods',
      'help_support': 'Help & Support',
      'logout': 'Log Out',
      'logout_confirm_title': 'Log Out',
      'logout_confirm_msg': 'Are you sure you want to log out?',
      'cancel': 'Cancel',
      'logout_btn': 'Log Out',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ru', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension LocalizationExtension on BuildContext {
  String translate(String key) {
    return AppLocalizations.of(this)?.translate(key) ?? key;
  }
}
