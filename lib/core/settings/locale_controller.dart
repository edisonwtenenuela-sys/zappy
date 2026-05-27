import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

class LocaleController {
  static const _localeKey = 'app_locale';

  Future<String> resolveInitialLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_localeKey);
    if (saved == 'es' || saved == 'en') {
      return saved!;
    }

    final system = PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    if (system.startsWith('es')) {
      return 'es';
    }
    return 'en';
  }

  Future<void> saveLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, code);
  }
}
