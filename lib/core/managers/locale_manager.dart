import 'dart:async';

import 'package:flutter/material.dart';
import 'package:guardiancare/core/services/locale_service.dart';
import 'package:guardiancare/core/util/logger.dart';

/// Abstract interface for locale management
/// Follows Single Responsibility Principle - only manages app locale
abstract class LocaleManager {
  /// Current application locale
  Locale get currentLocale;

  /// Stream of locale changes for reactive updates
  Stream<Locale> get localeChanges;

  /// Change the application locale
  void changeLocale(Locale newLocale);

  /// Load saved locale from storage
  Future<void> loadSavedLocale();

  /// Dispose resources
  void dispose();
}

/// Implementation of LocaleManager
/// Manages application locale and delegates persistence to LocaleService
class LocaleManagerImpl implements LocaleManager {
  LocaleManagerImpl({
    required LocaleService localeService,
    Locale defaultLocale = const Locale('en'),
  })  : _localeService = localeService,
        _currentLocale = defaultLocale {
    Log.d(
        'LocaleManager initialized with default locale: ${_currentLocale.languageCode}');
  }
  final LocaleService _localeService;
  final StreamController<Locale> _localeController =
      StreamController<Locale>.broadcast();

  Locale _currentLocale;

  @override
  Locale get currentLocale => _currentLocale;

  @override
  Stream<Locale> get localeChanges => _localeController.stream;

  @override
  void changeLocale(Locale newLocale) {
    Log.d('LocaleManager: Changing locale to ${newLocale.languageCode}');

    // Update current locale
    _currentLocale = newLocale;

    // Notify listeners
    _localeController.add(newLocale);

    // Persist to storage
    _localeService.saveLocale(newLocale);

    Log.d('LocaleManager: Locale changed to ${_currentLocale.languageCode}');
  }

  @override
  Future<void> loadSavedLocale() async {
    final savedLocale = _localeService.getSavedLocale();
    Log.d(
        'LocaleManager: Loading saved locale: ${savedLocale?.languageCode ?? "none (using default)"}');

    if (savedLocale != null) {
      _currentLocale = savedLocale;
      _localeController.add(savedLocale);
      Log.d('LocaleManager: Loaded locale: ${_currentLocale.languageCode}');
    }
  }

  @override
  void dispose() {
    _localeController.close();
    Log.d('LocaleManager disposed');
  }
}
