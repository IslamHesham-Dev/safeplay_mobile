import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocalePrefKey = 'safeplay.locale';

class LocaleProvider extends ChangeNotifier {
  LocaleProvider({Locale initialLocale = const Locale('en')})
      : _locale = initialLocale;

  Locale _locale;
  Locale get locale => _locale;

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLocalePrefKey);
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocalePrefKey, locale.languageCode);
  }

  Future<void> toggleLocale() async {
    final nextCode = _locale.languageCode == 'en' ? 'ar' : 'en';
    await setLocale(Locale(nextCode));
  }
}
