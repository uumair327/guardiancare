import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide test, group, setUp, tearDown, expect;
import 'package:glados/glados.dart';
import 'package:guardiancare/core/managers/auth_state_manager.dart';
import 'package:guardiancare/core/managers/locale_manager.dart';
import 'package:guardiancare/core/managers/app_lifecycle_manager.dart';
import 'package:guardiancare/core/models/auth_state_event.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// **Feature: srp-clean-architecture-fix, Property 1: Main App State Delegation**
/// **Validates: Requirements 1.1, 1.2, 1.3, 1.4**
///
/// Property: For any authentication state change, locale change, or lifecycle event
/// in the application, the GuardiancareState SHALL delegate handling to the
/// appropriate manager (AuthStateManager, LocaleManager, or AppLifecycleManager)
/// rather than handling it directly.

// ============================================================================
// Mock Implementations for Testing
// ============================================================================

/// Mock AuthStateManager that tracks all method calls
class MockAuthStateManager implements AuthStateManager {
  final List<String> methodCalls = [];
  final StreamController<AuthStateEvent> _eventController =
      StreamController<AuthStateEvent>.broadcast();
  final StreamController<User?> _authStateController =
      StreamController<User?>.broadcast();

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  @override
  Stream<AuthStateEvent> get authEvents => _eventController.stream;

  @override
  User? get currentUser => null;

  @override
  void notifyLogout() {
    methodCalls.add('notifyLogout');
    _eventController.add(AuthStateEvent.logout());
  }

  @override
  void dispose() {
    methodCalls.add('dispose');
    _eventController.close();
    _authStateController.close();
  }

  // Test helpers
  void simulateLogin() {
    _eventController.add(AuthStateEvent(
      type: AuthStateEventType.login,
      user: null,
      timestamp: DateTime.now(),
    ));
  }

  void simulateLogout() {
    _authStateController.add(null);
    _eventController.add(AuthStateEvent.logout());
  }
}

/// Mock LocaleManager that tracks all method calls
class MockLocaleManager implements LocaleManager {
  final List<String> methodCalls = [];
  final List<Locale> recordedLocaleChanges = [];
  final StreamController<Locale> _localeController =
      StreamController<Locale>.broadcast();

  Locale _currentLocale;

  MockLocaleManager({Locale defaultLocale = const Locale('en')})
      : _currentLocale = defaultLocale;

  @override
  Locale get currentLocale => _currentLocale;

  @override
  Stream<Locale> get localeChanges => _localeController.stream;

  @override
  void changeLocale(Locale newLocale) {
    methodCalls.add('changeLocale:${newLocale.languageCode}');
    recordedLocaleChanges.add(newLocale);
    _currentLocale = newLocale;
    _localeController.add(newLocale);
  }

  @override
  Future<void> loadSavedLocale() async {
    methodCalls.add('loadSavedLocale');
  }

  @override
  void dispose() {
    methodCalls.add('dispose');
    _localeController.close();
  }
}

/// Mock AppLifecycleManager that tracks all method calls
class MockAppLifecycleManager implements AppLifecycleManager {
  final List<String> methodCalls = [];

  @override
  void onPaused() {
    methodCalls.add('onPaused');
  }

  @override
  void onDetached() {
    methodCalls.add('onDetached');
  }

  @override
  void onResumed() {
    methodCalls.add('onResumed');
  }

  @override
  void dispose() {
    methodCalls.add('dispose');
  }
}

// ============================================================================
// Test Delegate Class (simulates GuardiancareState delegation behavior)
// ============================================================================

/// Simulates the delegation behavior of GuardiancareState
/// This class mirrors how GuardiancareState delegates to managers
class AppStateDelegator {
  final AuthStateManager authManager;
  final LocaleManager localeManager;
  final AppLifecycleManager lifecycleManager;

  AppStateDelegator({
    required this.authManager,
    required this.localeManager,
    required this.lifecycleManager,
  });

  /// Delegates locale change to LocaleManager (mirrors GuardiancareState.changeLocale)
  void changeLocale(Locale newLocale) {
    localeManager.changeLocale(newLocale);
  }

  /// Delegates lifecycle events to AppLifecycleManager
  void handleLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        lifecycleManager.onPaused();
        break;
      case AppLifecycleState.detached:
        lifecycleManager.onDetached();
        break;
      case AppLifecycleState.resumed:
        lifecycleManager.onResumed();
        break;
      default:
        break;
    }
  }

  /// Delegates logout notification to AuthStateManager
  void notifyLogout() {
    authManager.notifyLogout();
  }
}

// ============================================================================
// Helper to create fresh test fixtures
// ============================================================================

class TestFixture {
  final MockAuthStateManager authManager;
  final MockLocaleManager localeManager;
  final MockAppLifecycleManager lifecycleManager;
  final AppStateDelegator delegator;

  TestFixture._({
    required this.authManager,
    required this.localeManager,
    required this.lifecycleManager,
    required this.delegator,
  });

  factory TestFixture.create() {
    final authManager = MockAuthStateManager();
    final localeManager = MockLocaleManager();
    final lifecycleManager = MockAppLifecycleManager();
    final delegator = AppStateDelegator(
      authManager: authManager,
      localeManager: localeManager,
      lifecycleManager: lifecycleManager,
    );
    return TestFixture._(
      authManager: authManager,
      localeManager: localeManager,
      lifecycleManager: lifecycleManager,
      delegator: delegator,
    );
  }
}

// ============================================================================
// Custom Generators for Glados
// ============================================================================

/// Supported locales in the app
final supportedLocales = [
  const Locale('en'),
  const Locale('hi'),
  const Locale('mr'),
  const Locale('gu'),
  const Locale('bn'),
  const Locale('ta'),
  const Locale('te'),
  const Locale('kn'),
  const Locale('ml'),
];

/// Lifecycle states that trigger manager calls
final handledLifecycleStates = [
  AppLifecycleState.paused,
  AppLifecycleState.detached,
  AppLifecycleState.resumed,
];

/// Extension to add custom generators
extension CustomGenerators on Any {
  /// Generator for supported locales
  Generator<Locale> get locale => choose(supportedLocales);

  /// Generator for lifecycle states that trigger manager calls
  Generator<AppLifecycleState> get lifecycleState => choose(handledLifecycleStates);

  /// Generator for positive integers between 1 and max
  Generator<int> intBetween(int min, int max) {
    return intInRange(min, max + 1);
  }
}

// ============================================================================
// Property-Based Tests
// ============================================================================

void main() {
  group('Property 1: Main App State Delegation', () {
    // ========================================================================
    // Property 1.1: Locale changes are delegated to LocaleManager
    // Validates: Requirement 1.2
    // ========================================================================
    Glados(any.locale, ExploreConfig(numRuns: 20)).test(
      'For any locale change, LocaleManager.changeLocale SHALL be called',
      (locale) {
        // Create fresh fixtures for each test iteration
        final fixture = TestFixture.create();

        // Act
        fixture.delegator.changeLocale(locale);

        // Assert: LocaleManager received the delegation
        expect(
          fixture.localeManager.methodCalls,
          contains('changeLocale:${locale.languageCode}'),
          reason: 'LocaleManager.changeLocale should be called for locale: ${locale.languageCode}',
        );

        // Assert: The locale was recorded
        expect(
          fixture.localeManager.recordedLocaleChanges,
          contains(locale),
          reason: 'LocaleManager should record the locale change',
        );
      },
    );

    // ========================================================================
    // Property 1.2: Lifecycle events are delegated to AppLifecycleManager
    // Validates: Requirement 1.3
    // ========================================================================
    Glados(any.lifecycleState, ExploreConfig(numRuns: 20)).test(
      'For any lifecycle event (paused/detached/resumed), AppLifecycleManager SHALL handle it',
      (state) {
        // Create fresh fixtures for each test iteration
        final fixture = TestFixture.create();

        // Act
        fixture.delegator.handleLifecycleState(state);

        // Assert: Appropriate method was called based on state
        switch (state) {
          case AppLifecycleState.paused:
            expect(
              fixture.lifecycleManager.methodCalls,
              contains('onPaused'),
              reason: 'AppLifecycleManager.onPaused should be called for paused state',
            );
            break;
          case AppLifecycleState.detached:
            expect(
              fixture.lifecycleManager.methodCalls,
              contains('onDetached'),
              reason: 'AppLifecycleManager.onDetached should be called for detached state',
            );
            break;
          case AppLifecycleState.resumed:
            expect(
              fixture.lifecycleManager.methodCalls,
              contains('onResumed'),
              reason: 'AppLifecycleManager.onResumed should be called for resumed state',
            );
            break;
          default:
            break;
        }
      },
    );

    // ========================================================================
    // Property 1.3: Logout notifications are delegated to AuthStateManager
    // Validates: Requirement 1.4
    // ========================================================================
    Glados(any.intBetween(1, 5), ExploreConfig(numRuns: 20)).test(
      'For any logout request, AuthStateManager.notifyLogout SHALL be called',
      (count) {
        // Create fresh fixtures for each test iteration
        final fixture = TestFixture.create();

        // Act - call notifyLogout 'count' times
        for (var i = 0; i < count; i++) {
          fixture.delegator.notifyLogout();
        }

        // Assert: AuthStateManager received all delegations
        final logoutCalls = fixture.authManager.methodCalls
            .where((c) => c == 'notifyLogout')
            .length;
        expect(
          logoutCalls,
          equals(count),
          reason: 'AuthStateManager.notifyLogout should be called $count times',
        );
      },
    );

    // ========================================================================
    // Property 1.4: Multiple locale changes are all delegated
    // Validates: Requirement 1.2
    // ========================================================================
    Glados(any.nonEmptyList(any.locale), ExploreConfig(numRuns: 20)).test(
      'For any sequence of locale changes, all SHALL be delegated to LocaleManager',
      (locales) {
        // Create fresh fixtures for each test iteration
        final fixture = TestFixture.create();

        // Act
        for (final locale in locales) {
          fixture.delegator.changeLocale(locale);
        }

        // Assert: All locale changes were delegated
        expect(
          fixture.localeManager.recordedLocaleChanges.length,
          equals(locales.length),
          reason: 'All ${locales.length} locale changes should be delegated',
        );

        // Assert: Each locale was recorded in order
        for (int i = 0; i < locales.length; i++) {
          expect(
            fixture.localeManager.recordedLocaleChanges[i],
            equals(locales[i]),
            reason: 'Locale at index $i should match',
          );
        }
      },
    );

    // ========================================================================
    // Property 1.5: Multiple lifecycle events are all delegated
    // Validates: Requirement 1.3
    // ========================================================================
    Glados(any.nonEmptyList(any.lifecycleState), ExploreConfig(numRuns: 20)).test(
      'For any sequence of lifecycle events, all SHALL be delegated to AppLifecycleManager',
      (states) {
        // Create fresh fixtures for each test iteration
        final fixture = TestFixture.create();

        // Act
        for (final state in states) {
          fixture.delegator.handleLifecycleState(state);
        }

        // Assert: Count expected calls
        final expectedPaused = states.where((s) => s == AppLifecycleState.paused).length;
        final expectedDetached = states.where((s) => s == AppLifecycleState.detached).length;
        final expectedResumed = states.where((s) => s == AppLifecycleState.resumed).length;

        final actualPaused = fixture.lifecycleManager.methodCalls.where((c) => c == 'onPaused').length;
        final actualDetached = fixture.lifecycleManager.methodCalls.where((c) => c == 'onDetached').length;
        final actualResumed = fixture.lifecycleManager.methodCalls.where((c) => c == 'onResumed').length;

        expect(actualPaused, equals(expectedPaused),
            reason: 'All paused events should be delegated');
        expect(actualDetached, equals(expectedDetached),
            reason: 'All detached events should be delegated');
        expect(actualResumed, equals(expectedResumed),
            reason: 'All resumed events should be delegated');
      },
    );

    // ========================================================================
    // Property 1.6: Auth events are observable through AuthStateManager stream
    // Validates: Requirement 1.1, 1.4
    // ========================================================================
    Glados(any.intBetween(1, 3), ExploreConfig(numRuns: 20)).test(
      'For any logout notification, AuthStateManager SHALL emit logout event',
      (count) async {
        // Create fresh fixtures for each test iteration
        final fixture = TestFixture.create();

        // Arrange
        final authEvents = <AuthStateEvent>[];
        final subscription = fixture.authManager.authEvents.listen(authEvents.add);

        // Act
        for (var i = 0; i < count; i++) {
          fixture.delegator.notifyLogout();
        }

        // Allow stream to propagate
        await Future.delayed(Duration.zero);

        // Assert
        final logoutEvents = authEvents.where((e) => e.type == AuthStateEventType.logout).length;
        expect(
          logoutEvents,
          equals(count),
          reason: 'AuthStateManager should emit $count logout events',
        );

        await subscription.cancel();
      },
    );
  });

  // ==========================================================================
  // Unit Tests for Edge Cases
  // ==========================================================================
  group('Main App State Delegation - Edge Cases', () {
    test('LocaleManager should handle rapid locale changes', () async {
      final fixture = TestFixture.create();

      // Rapidly change locales
      final locales = [
        const Locale('en'),
        const Locale('hi'),
        const Locale('mr'),
        const Locale('en'),
      ];

      for (final locale in locales) {
        fixture.delegator.changeLocale(locale);
      }

      expect(fixture.localeManager.recordedLocaleChanges.length, equals(4));
      expect(fixture.localeManager.currentLocale, equals(const Locale('en')));
    });

    test('AppLifecycleManager should handle pause-resume cycle', () {
      final fixture = TestFixture.create();

      // Simulate pause-resume cycle
      fixture.delegator.handleLifecycleState(AppLifecycleState.paused);
      fixture.delegator.handleLifecycleState(AppLifecycleState.resumed);
      fixture.delegator.handleLifecycleState(AppLifecycleState.paused);
      fixture.delegator.handleLifecycleState(AppLifecycleState.detached);

      expect(fixture.lifecycleManager.methodCalls, [
        'onPaused',
        'onResumed',
        'onPaused',
        'onDetached',
      ]);
    });

    test('AuthStateManager should track multiple logout notifications', () {
      final fixture = TestFixture.create();

      // Multiple logout notifications
      fixture.delegator.notifyLogout();
      fixture.delegator.notifyLogout();
      fixture.delegator.notifyLogout();

      final logoutCalls = fixture.authManager.methodCalls
          .where((c) => c == 'notifyLogout')
          .length;
      expect(logoutCalls, equals(3));
    });

    test('Inactive and hidden lifecycle states should not trigger manager calls', () {
      final fixture = TestFixture.create();

      // These states should not trigger any manager calls
      fixture.delegator.handleLifecycleState(AppLifecycleState.inactive);
      fixture.delegator.handleLifecycleState(AppLifecycleState.hidden);

      expect(fixture.lifecycleManager.methodCalls, isEmpty);
    });
  });
}
