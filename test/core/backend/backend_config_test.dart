import 'package:flutter_test/flutter_test.dart';
import 'package:guardiancare/core/backend/backend.dart';

/// Tests for [BackendConfig] flag-driven configuration.
///
/// These tests verify the backend configuration system works correctly.
/// Note: Since BackendConfig uses compile-time constants, we test the
/// static behavior and structure rather than runtime flag changes.
void main() {
  group('BackendConfig', () {
    test('provider returns a valid BackendProvider', () {
      // Should return a valid enum value
      expect(BackendConfig.provider, isA<BackendProvider>());
    });

    test('default provider is firebase', () {
      // When no --dart-define is set, should default to Firebase
      // This is the expected behavior for the default configuration
      expect(BackendConfig.provider, equals(BackendProvider.firebase));
    });

    test('hasSupabaseFeatures is false by default', () {
      // In default config, no Supabase features are enabled
      // Note: will be true if global provider is supabase or any granular flag is true
      // In tests without dart-define, should be false
      expect(BackendConfig.hasSupabaseFeatures, isFalse);
    });

    test('hasFirebaseFeatures is true for default config', () {
      // When using Firebase as default provider
      expect(BackendConfig.hasFirebaseFeatures, isTrue);
    });

    test('debugInfo returns a valid map with expected keys', () {
      final info = BackendConfig.debugInfo;

      expect(info, isA<Map<String, dynamic>>());
      expect(info.containsKey('globalProvider'), isTrue);
      expect(info.containsKey('resolvedProviders'), isTrue);
      expect(info.containsKey('featureFlags'), isTrue);
      expect(info.containsKey('hasSupabaseFeatures'), isTrue);
      expect(info.containsKey('hasFirebaseFeatures'), isTrue);
    });

    test('debugInfo resolvedProviders contains all services', () {
      final resolved =
          BackendConfig.debugInfo['resolvedProviders'] as Map<String, dynamic>;

      expect(resolved.containsKey('auth'), isTrue);
      expect(resolved.containsKey('database'), isTrue);
      expect(resolved.containsKey('storage'), isTrue);
      expect(resolved.containsKey('realtime'), isTrue);
    });

    test('debugInfo featureFlags contains all flags', () {
      final flags =
          BackendConfig.debugInfo['featureFlags'] as Map<String, dynamic>;

      expect(flags.containsKey('useSupabaseAuth'), isTrue);
      expect(flags.containsKey('useSupabaseDatabase'), isTrue);
      expect(flags.containsKey('useSupabaseStorage'), isTrue);
      expect(flags.containsKey('useSupabaseRealtime'), isTrue);
    });

    test('authProvider returns valid provider', () {
      expect(BackendConfig.authProvider, isA<BackendProvider>());
    });

    test('databaseProvider returns valid provider', () {
      expect(BackendConfig.databaseProvider, isA<BackendProvider>());
    });

    test('storageProvider returns valid provider', () {
      expect(BackendConfig.storageProvider, isA<BackendProvider>());
    });

    test('realtimeProvider returns valid provider', () {
      expect(BackendConfig.realtimeProvider, isA<BackendProvider>());
    });

    test('all resolved providers default to firebase', () {
      // When no --dart-define flags are set, all should default to firebase
      expect(BackendConfig.authProvider, equals(BackendProvider.firebase));
      expect(BackendConfig.databaseProvider, equals(BackendProvider.firebase));
      expect(BackendConfig.storageProvider, equals(BackendProvider.firebase));
      expect(BackendConfig.realtimeProvider, equals(BackendProvider.firebase));
    });

    test('isFirebase is true when provider is firebase', () {
      expect(BackendConfig.isFirebase, isTrue);
    });

    test('isSupabase is false when provider is firebase', () {
      expect(BackendConfig.isSupabase, isFalse);
    });

    test('granular flags are false by default', () {
      expect(BackendConfig.useSupabaseAuth, isFalse);
      expect(BackendConfig.useSupabaseDatabase, isFalse);
      expect(BackendConfig.useSupabaseStorage, isFalse);
      expect(BackendConfig.useSupabaseRealtime, isFalse);
    });
  });

  group('BackendProvider enum', () {
    test('has all expected providers', () {
      expect(BackendProvider.values, contains(BackendProvider.firebase));
      expect(BackendProvider.values, contains(BackendProvider.supabase));
      expect(BackendProvider.values, contains(BackendProvider.appwrite));
      expect(BackendProvider.values, contains(BackendProvider.custom));
    });

    test('providers are distinct', () {
      final values = BackendProvider.values;
      final uniqueNames = values.map((e) => e.name).toSet();
      expect(uniqueNames.length, equals(values.length));
    });

    test('has exactly 4 providers', () {
      expect(BackendProvider.values.length, equals(4));
    });
  });
}
