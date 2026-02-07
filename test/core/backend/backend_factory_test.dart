import 'package:flutter_test/flutter_test.dart';
import 'package:guardiancare/core/backend/backend.dart';

/// Tests for [BackendFactory] adapter resolution.
///
/// These tests verify that the BackendFactory correctly creates
/// adapters based on the configured provider.
///
/// Note: Tests that instantiate Firebase adapters are skipped in unit tests
/// since they require Firebase to be initialized. They would pass in
/// integration tests where Firebase is properly set up.
void main() {
  group('BackendFactory', () {
    group('construction', () {
      test('can be instantiated without provider', () {
        const factory = BackendFactory();
        expect(factory, isNotNull);
      });

      test('can be instantiated with explicit provider', () {
        const factory = BackendFactory(BackendProvider.firebase);
        expect(factory, isNotNull);
        expect(factory.provider, equals(BackendProvider.firebase));
      });

      test('provider defaults to config when not explicit', () {
        const factory = BackendFactory();
        // Without explicit provider, should use BackendConfig.provider
        expect(factory.provider, equals(BackendConfig.provider));
      });

      test('can create factory with supabase provider', () {
        const factory = BackendFactory(BackendProvider.supabase);
        expect(factory.provider, equals(BackendProvider.supabase));
      });

      test('can create factory with appwrite provider', () {
        const factory = BackendFactory(BackendProvider.appwrite);
        expect(factory.provider, equals(BackendProvider.appwrite));
      });

      test('can create factory with custom provider', () {
        const factory = BackendFactory(BackendProvider.custom);
        expect(factory.provider, equals(BackendProvider.custom));
      });
    });

    group('Supabase adapter creation (throws StateError when not initialized)',
        () {
      const factory = BackendFactory(BackendProvider.supabase);

      test('createAuthService tries to create SupabaseAuthAdapter', () {
        // Should throw StateError because Supabase is not initialized in tests
        expect(
          () => factory.createAuthService(),
          throwsA(isA<StateError>()),
        );
      });

      test('createDataStore tries to create SupabaseDataStoreAdapter', () {
        expect(
          () => factory.createDataStore(),
          throwsA(isA<StateError>()),
        );
      });

      test('createStorageService tries to create SupabaseStorageAdapter', () {
        expect(
          () => factory.createStorageService(),
          throwsA(isA<StateError>()),
        );
      });

      test('createRealtimeService tries to create SupabaseRealtimeAdapter', () {
        expect(
          () => factory.createRealtimeService(),
          throwsA(isA<StateError>()),
        );
      });

      test('createAnalyticsService returns NoOpAnalyticsAdapter', () {
        // Analytics should fallback to NoOp for non-Firebase
        final analytics = factory.createAnalyticsService();
        expect(analytics, isA<IAnalyticsService>());
        expect(analytics, isA<NoOpAnalyticsAdapter>());
      });

      test('createAll throws StateError', () {
        expect(
          () => factory.createAll(),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('Appwrite adapter creation (throws UnimplementedError)', () {
      const factory = BackendFactory(BackendProvider.appwrite);

      test('createAuthService throws UnimplementedError', () {
        expect(() => factory.createAuthService(),
            throwsA(isA<UnimplementedError>()));
      });

      test('createDataStore throws UnimplementedError', () {
        expect(() => factory.createDataStore(),
            throwsA(isA<UnimplementedError>()));
      });

      test('createStorageService throws UnimplementedError', () {
        expect(() => factory.createStorageService(),
            throwsA(isA<UnimplementedError>()));
      });

      test('createRealtimeService throws UnimplementedError', () {
        expect(() => factory.createRealtimeService(),
            throwsA(isA<UnimplementedError>()));
      });

      test('createAnalyticsService returns NoOpAnalyticsAdapter', () {
        final analytics = factory.createAnalyticsService();
        expect(analytics, isA<NoOpAnalyticsAdapter>());
      });
    });

    group('Custom adapter creation (throws UnimplementedError)', () {
      const factory = BackendFactory(BackendProvider.custom);

      test('createAuthService throws UnimplementedError', () {
        expect(() => factory.createAuthService(),
            throwsA(isA<UnimplementedError>()));
      });

      test('createDataStore throws UnimplementedError', () {
        expect(() => factory.createDataStore(),
            throwsA(isA<UnimplementedError>()));
      });

      test('createStorageService throws UnimplementedError', () {
        expect(() => factory.createStorageService(),
            throwsA(isA<UnimplementedError>()));
      });

      test('createRealtimeService throws UnimplementedError', () {
        expect(() => factory.createRealtimeService(),
            throwsA(isA<UnimplementedError>()));
      });

      test('createAnalyticsService returns NoOpAnalyticsAdapter', () {
        final analytics = factory.createAnalyticsService();
        expect(analytics, isA<NoOpAnalyticsAdapter>());
      });
    });

    // Note: Firebase adapter creation tests are skipped in unit tests
    // They require Firebase to be initialized which happens in main.dart
    // These tests would pass in integration tests
    group('Firebase adapter creation (requires Firebase initialization)', () {
      // Factory is created but tests are skipped - this verifies const construction works
      test('factory can be const-constructed for Firebase', () {
        const factory = BackendFactory(BackendProvider.firebase);
        expect(factory.provider, equals(BackendProvider.firebase));
      });

      test('createAuthService returns correct type', () {
        // Skip: Requires Firebase.initializeApp()
        // In unit tests, we verify the factory logic, not Firebase initialization
      }, skip: 'Requires Firebase initialization');

      test('createDataStore returns correct type', () {
        // Skip: Requires Firebase.initializeApp()
      }, skip: 'Requires Firebase initialization');

      test('createStorageService returns correct type', () {
        // Skip: Requires Firebase.initializeApp()
      }, skip: 'Requires Firebase initialization');

      test('createAnalyticsService returns correct type', () {
        // Skip: Requires Firebase.initializeApp()
      }, skip: 'Requires Firebase initialization');

      test('createRealtimeService returns correct type', () {
        // Skip: Requires Firebase.initializeApp()
      }, skip: 'Requires Firebase initialization');

      test('createAll returns BackendServices', () {
        // Skip: Requires Firebase.initializeApp()
      }, skip: 'Requires Firebase initialization');
    });
  });

  group('BackendServices', () {
    test('is a valid class', () {
      // Just verify the class exists and can be referenced
      expect(BackendServices, isNotNull);
    });
  });

  group('NoOpAnalyticsAdapter', () {
    test('can be instantiated', () {
      const adapter = NoOpAnalyticsAdapter();
      expect(adapter, isNotNull);
      expect(adapter, isA<IAnalyticsService>());
    });

    test('logEvent completes successfully', () async {
      const adapter = NoOpAnalyticsAdapter();
      final result = await adapter.logEvent(name: 'test_event');
      expect(result.isSuccess, isTrue);
    });

    test('setUserId completes successfully', () async {
      const adapter = NoOpAnalyticsAdapter();
      final result = await adapter.setUserId('user123');
      expect(result.isSuccess, isTrue);
    });

    test('setUserProperty completes successfully', () async {
      const adapter = NoOpAnalyticsAdapter();
      final result =
          await adapter.setUserProperty(name: 'test', value: 'value');
      expect(result.isSuccess, isTrue);
    });
  });
}
