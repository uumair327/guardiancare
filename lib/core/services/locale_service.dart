import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app locale/language
/// Follows Clean Architecture - Infrastructure layer service
class LocaleService {

  LocaleService(this._prefs);
  static const String _localeKey = 'app_locale';
  final SharedPreferences _prefs;

  /// Get saved locale from storage
  Locale? getSavedLocale() {
    final localeCode = _prefs.getString(_localeKey);
    if (localeCode == null) return null;
    
    // Handle language codes with country codes (e.g., 'en_US')
    final parts = localeCode.split('_');
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(localeCode);
  }

  /// Save locale to storage
  Future<bool> saveLocale(Locale locale) async {
    final localeCode = locale.countryCode != null
        ? '${locale.languageCode}_${locale.countryCode}'
        : locale.languageCode;
    return _prefs.setString(_localeKey, localeCode);
  }

  /// Clear saved locale (will use system default)
  Future<bool> clearLocale() async {
    return _prefs.remove(_localeKey);
  }

  /// Get all supported locales
  static List<LocaleInfo> getSupportedLocales() {
    return [
      LocaleInfo(
        locale: const Locale('en'),
        name: 'English',
        nativeName: 'English',
        flag: '🇬🇧',
      ),
      LocaleInfo(
        locale: const Locale('hi'),
        name: 'Hindi',
        nativeName: 'हिन्दी',
        flag: '🇮🇳',
      ),
      LocaleInfo(
        locale: const Locale('mr'),
        name: 'Marathi',
        nativeName: 'मराठी',
        flag: '🇮🇳',
      ),
      LocaleInfo(
        locale: const Locale('gu'),
        name: 'Gujarati',
        nativeName: 'ગુજરાતી',
        flag: '🇮🇳',
      ),
      LocaleInfo(
        locale: const Locale('bn'),
        name: 'Bengali',
        nativeName: 'বাংলা',
        flag: '🇮🇳',
      ),
      LocaleInfo(
        locale: const Locale('ta'),
        name: 'Tamil',
        nativeName: 'தமிழ்',
        flag: '🇮🇳',
      ),
      LocaleInfo(
        locale: const Locale('te'),
        name: 'Telugu',
        nativeName: 'తెలుగు',
        flag: '🇮🇳',
      ),
      LocaleInfo(
        locale: const Locale('kn'),
        name: 'Kannada',
        nativeName: 'ಕನ್ನಡ',
        flag: '🇮🇳',
      ),
      LocaleInfo(
        locale: const Locale('ml'),
        name: 'Malayalam',
        nativeName: 'മലയാളം',
        flag: '🇮🇳',
      ),
    ];
  }
}

/// Model class for locale information
class LocaleInfo {

  LocaleInfo({
    required this.locale,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
  final Locale locale;
  final String name;
  final String nativeName;
  final String flag;

  String get displayName => '$flag $nativeName';
  String get fullDisplayName => '$flag $nativeName ($name)';
}
