import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static final LanguageService _instance = LanguageService._internal();

  factory LanguageService() {
    return _instance;
  }

  LanguageService._internal();

  // Language change notifier
  final ValueNotifier<Locale> localeNotifier = ValueNotifier<Locale>(
    const Locale('en'),
  );

  // Initialize language from saved preferences
  Future<void> initLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString('selected_language') ?? 'English';
      setLanguage(savedLanguage, notify: false);
    } catch (e) {
      print('Error loading saved language: $e');
    }
  }

  // Set language and save to preferences
  Future<void> setLanguage(String language, {bool notify = true}) async {
    Locale newLocale;
    switch (language) {
      case 'Hindi':
        newLocale = const Locale('hi');
        break;
      case 'Marathi':
        newLocale = const Locale('mr');
        break;
      case 'Telugu':
        newLocale = const Locale('te');
        break;
      case 'Tamil':
        newLocale = const Locale('ta');
        break;
      default:
        newLocale = const Locale('en');
    }

    // Save to preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language', language);
    } catch (e) {
      print('Error saving language preference: $e');
    }

    // Update locale notifier
    if (notify) {
      localeNotifier.value = newLocale;
    } else {
      localeNotifier.value = newLocale;
    }
  }

  // Get current language name
  String getCurrentLanguageName() {
    final locale = localeNotifier.value.languageCode;
    switch (locale) {
      case 'hi':
        return 'Hindi';
      case 'mr':
        return 'Marathi';
      case 'te':
        return 'Telugu';
      case 'ta':
        return 'Tamil';
      default:
        return 'English';
    }
  }
}
