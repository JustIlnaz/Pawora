import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/locale_provider.dart';
import '../utils/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.translate('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          SwitchListTile(
            title: Text(context.translate('notifications')),
            subtitle: Text(context.translate('notifications_sub')),
            value: true,
            onChanged: (bool value) {},
            activeTrackColor: Theme.of(context).colorScheme.primary,
          ),
          const Divider(),
          SwitchListTile(
            title: Text(context.translate('dark_theme')),
            subtitle: Text(themeProvider.isDark
                ? context.translate('theme_enabled')
                : context.translate('theme_disabled')),
            value: themeProvider.isDark,
            onChanged: (_) => themeProvider.toggleTheme(),
            activeTrackColor: Theme.of(context).colorScheme.primary,
            secondary: Icon(
              themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(context.translate('language')),
            subtitle: Text(localeProvider.locale.languageCode == 'ru'
                ? context.translate('russian')
                : context.translate('english')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(context.translate('language')),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text(context.translate('russian')),
                        trailing: localeProvider.locale.languageCode == 'ru'
                            ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                            : null,
                        onTap: () {
                          localeProvider.setLocale(const Locale('ru'));
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: Text(context.translate('english')),
                        trailing: localeProvider.locale.languageCode == 'en'
                            ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                            : null,
                        onTap: () {
                          localeProvider.setLocale(const Locale('en'));
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: Text(context.translate('about_pawora')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            title: Text(context.translate('privacy_policy')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
