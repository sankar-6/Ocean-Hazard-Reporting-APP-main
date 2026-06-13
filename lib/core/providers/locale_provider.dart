import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Simple locale provider using AsyncNotifier
class LocaleNotifier extends AsyncNotifier<Locale> {
  @override
  Future<Locale> build() async {
    // Load saved locale from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('selected_locale');

    if (savedLocale != null) {
      return Locale(savedLocale);
    }

    return const Locale('en');
  }

  // Change locale and persist it
  Future<void> changeLocale(Locale locale) async {
    state = AsyncValue.data(locale);

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_locale', locale.languageCode);
  }
}

// Locale provider
final localeProvider = AsyncNotifierProvider<LocaleNotifier, Locale>(() {
  return LocaleNotifier();
});

// Supported locales
const List<Locale> supportedLocales = [
  Locale('en'), // English
  Locale('hi'), // Hindi
  Locale('te'), // Telugu
];

// Locale info class for UI
class LocaleInfo {
  final Locale locale;
  final String name;
  final String nativeName;
  final String flag;

  const LocaleInfo({
    required this.locale,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

// Available locales for selection
const List<LocaleInfo> availableLocales = [
  LocaleInfo(
    locale: Locale('en'),
    name: 'English',
    nativeName: 'English',
    flag: '🇺🇸',
  ),
  LocaleInfo(
    locale: Locale('hi'),
    name: 'Hindi',
    nativeName: 'हिन्दी',
    flag: '🇮🇳',
  ),
  LocaleInfo(
    locale: Locale('te'),
    name: 'Telugu',
    nativeName: 'తెలుగు',
    flag: '🇮🇳',
  ),
];

// Helper function to get locale info
LocaleInfo getLocaleInfo(Locale locale) {
  return availableLocales.firstWhere(
    (info) => info.locale.languageCode == locale.languageCode,
    orElse: () => availableLocales.first,
  );
}
