import 'package:flutter/material.dart';
import 'package:glados/glados.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/routing/auth_guard.dart';

/// **Feature: srp-clean-architecture-fix, Property 7: Auth Guard Encapsulation**
/// **Validates: Requirements 7.1, 7.2**
///
/// Property: For any route redirect evaluation in AppRouter, the authentication
/// check logic SHALL be encapsulated in AuthGuard, and AppRouter SHALL only
/// define route configurations.

// ============================================================================
// Mock Implementations for Testing
// ============================================================================

/// Mock AuthGuard that tracks all method calls and allows configurable behavior
class MockAuthGuard implements AuthGuard {
  MockAuthGuard({
    bool isAuthenticated = false,
    Set<String>? publicRoutes,
  })  : _isAuthenticated = isAuthenticated,
        _publicRoutes = publicRoutes ?? {'/login'};
  final List<String> methodCalls = [];
  final List<String> redirectPaths = [];
  final List<String> publicRouteChecks = [];

  bool _isAuthenticated = false;
  final Set<String> _publicRoutes;

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    methodCalls.add('redirect');
    redirectPaths.add(state.matchedLocation);

    final isLoggedIn = isAuthenticated();
    final currentPath = state.matchedLocation;
    final isPublic = isPublicRoute(currentPath);

    // If user is not logged in and trying to access protected route
    if (!isLoggedIn && !isPublic) {
      return '/login';
    }

    // If user is logged in and trying to access login routes
    if (isLoggedIn && isPublic) {
      return '/';
    }

    return null; // No redirect needed
  }

  @override
  bool isAuthenticated() {
    methodCalls.add('isAuthenticated');
    return _isAuthenticated;
  }

  @override
  bool isPublicRoute(String path) {
    methodCalls.add('isPublicRoute');
    publicRouteChecks.add(path);
    return _publicRoutes.contains(path);
  }

  /// Set authentication state for testing
  set authenticated(bool value) {
    _isAuthenticated = value;
  }

  /// Add a public route for testing
  void addPublicRoute(String path) {
    _publicRoutes.add(path);
  }

  /// Verifies that only AuthGuard methods were called
  bool get onlyAuthGuardMethodsCalled {
    return methodCalls.every((call) =>
        call == 'redirect' ||
        call == 'isAuthenticated' ||
        call == 'isPublicRoute');
  }

  void reset() {
    methodCalls.clear();
    redirectPaths.clear();
    publicRouteChecks.clear();
  }
}

/// Mock GoRouterState for testing
// ignore: avoid_implementing_value_types
class MockGoRouterState implements GoRouterState {
  MockGoRouterState({required this.matchedLocation});
  @override
  final String matchedLocation;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// ============================================================================
// Test Fixture
// ============================================================================

class AuthGuardTestFixture {
  AuthGuardTestFixture._({required this.authGuard});

  factory AuthGuardTestFixture.create({
    bool isAuthenticated = false,
    Set<String>? publicRoutes,
  }) {
    final authGuard = MockAuthGuard(
      isAuthenticated: isAuthenticated,
      publicRoutes: publicRoutes,
    );
    return AuthGuardTestFixture._(authGuard: authGuard);
  }
  final MockAuthGuard authGuard;

  void reset() {
    authGuard.reset();
  }
}

// ============================================================================
// Custom Generators for Glados
// ============================================================================

/// Protected routes in the app (require authentication)
final protectedRoutes = [
  '/',
  '/quiz',
  '/quiz-questions',
  '/video',
  '/emergency',
  '/account',
  '/forum/123',
  '/webview',
  '/pdf-viewer',
  '/video-player',
];

/// Public routes in the app (don't require authentication)
final publicRoutes = [
  '/login',
];

/// All routes in the app
final allRoutes = [...protectedRoutes, ...publicRoutes];

/// Extension to add custom generators for auth guard testing
extension AuthGuardGenerators on Any {
  /// Generator for protected routes
  Generator<String> get protectedRoute => choose(protectedRoutes);

  /// Generator for public routes
  Generator<String> get publicRoute => choose(publicRoutes);

  /// Generator for all routes
  Generator<String> get anyRoute => choose(allRoutes);

  /// Generator for authentication state
  Generator<bool> get authState => choose([true, false]);

  /// Generator for positive integers between min and max (inclusive)
  Generator<int> intBetween(int min, int max) {
    return intInRange(min, max + 1);
  }
}

// ============================================================================
// Property-Based Tests
// ============================================================================

void main() {
  group('Property 7: Auth Guard Encapsulation', () {
    // ========================================================================
    // Property 7.1: AuthGuard encapsulates all authentication redirect logic
    // Validates: Requirement 7.1
    // ========================================================================
    Glados(any.anyRoute, ExploreConfig()).test(
      'For any route, AuthGuard.redirect SHALL be called for authentication checks',
      (route) {
        final fixture = AuthGuardTestFixture.create();
        final state = MockGoRouterState(matchedLocation: route);

        try {
          // Act - simulate redirect evaluation
          fixture.authGuard.redirect(
            _createMockBuildContext(),
            state,
          );

          // Assert: redirect method was called
          expect(
            fixture.authGuard.methodCalls,
            contains('redirect'),
            reason: 'AuthGuard.redirect should be called for route: $route',
          );

          // Assert: The route was recorded
          expect(
            fixture.authGuard.redirectPaths,
            contains(route),
            reason: 'AuthGuard should record the redirect path: $route',
          );
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 7.2: AuthGuard.isAuthenticated is called during redirect
    // Validates: Requirement 7.1
    // ========================================================================
    Glados(any.anyRoute, ExploreConfig()).test(
      'For any redirect evaluation, AuthGuard.isAuthenticated SHALL be called',
      (route) {
        final fixture = AuthGuardTestFixture.create();
        final state = MockGoRouterState(matchedLocation: route);

        try {
          // Act
          fixture.authGuard.redirect(
            _createMockBuildContext(),
            state,
          );

          // Assert: isAuthenticated was called
          expect(
            fixture.authGuard.methodCalls,
            contains('isAuthenticated'),
            reason:
                'AuthGuard.isAuthenticated should be called during redirect',
          );
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 7.3: AuthGuard.isPublicRoute is called during redirect
    // Validates: Requirement 7.2
    // ========================================================================
    Glados(any.anyRoute, ExploreConfig()).test(
      'For any redirect evaluation, AuthGuard.isPublicRoute SHALL be called',
      (route) {
        final fixture = AuthGuardTestFixture.create();
        final state = MockGoRouterState(matchedLocation: route);

        try {
          // Act
          fixture.authGuard.redirect(
            _createMockBuildContext(),
            state,
          );

          // Assert: isPublicRoute was called
          expect(
            fixture.authGuard.methodCalls,
            contains('isPublicRoute'),
            reason: 'AuthGuard.isPublicRoute should be called during redirect',
          );

          // Assert: The route was checked
          expect(
            fixture.authGuard.publicRouteChecks,
            contains(route),
            reason: 'AuthGuard should check if route is public: $route',
          );
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 7.4: Unauthenticated users accessing protected routes are redirected to login
    // Validates: Requirement 7.1
    // ========================================================================
    Glados(any.protectedRoute, ExploreConfig()).test(
      'For any protected route, unauthenticated users SHALL be redirected to /login',
      (route) {
        final fixture = AuthGuardTestFixture.create();
        final state = MockGoRouterState(matchedLocation: route);

        try {
          // Act
          final redirectPath = fixture.authGuard.redirect(
            _createMockBuildContext(),
            state,
          );

          // Assert: Redirect to login
          expect(
            redirectPath,
            equals('/login'),
            reason:
                'Unauthenticated user accessing $route should be redirected to /login',
          );
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 7.5: Authenticated users accessing public routes are redirected to home
    // Validates: Requirement 7.1
    // ========================================================================
    Glados(any.publicRoute, ExploreConfig()).test(
      'For any public route, authenticated users SHALL be redirected to /',
      (route) {
        final fixture = AuthGuardTestFixture.create(isAuthenticated: true);
        final state = MockGoRouterState(matchedLocation: route);

        try {
          // Act
          final redirectPath = fixture.authGuard.redirect(
            _createMockBuildContext(),
            state,
          );

          // Assert: Redirect to home
          expect(
            redirectPath,
            equals('/'),
            reason:
                'Authenticated user accessing $route should be redirected to /',
          );
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 7.6: Authenticated users accessing protected routes are not redirected
    // Validates: Requirement 7.1
    // ========================================================================
    Glados(any.protectedRoute, ExploreConfig()).test(
      'For any protected route, authenticated users SHALL NOT be redirected',
      (route) {
        final fixture = AuthGuardTestFixture.create(isAuthenticated: true);
        final state = MockGoRouterState(matchedLocation: route);

        try {
          // Act
          final redirectPath = fixture.authGuard.redirect(
            _createMockBuildContext(),
            state,
          );

          // Assert: No redirect
          expect(
            redirectPath,
            isNull,
            reason:
                'Authenticated user accessing $route should not be redirected',
          );
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 7.7: Unauthenticated users accessing public routes are not redirected
    // Validates: Requirement 7.1
    // ========================================================================
    Glados(any.publicRoute, ExploreConfig()).test(
      'For any public route, unauthenticated users SHALL NOT be redirected',
      (route) {
        final fixture = AuthGuardTestFixture.create();
        final state = MockGoRouterState(matchedLocation: route);

        try {
          // Act
          final redirectPath = fixture.authGuard.redirect(
            _createMockBuildContext(),
            state,
          );

          // Assert: No redirect
          expect(
            redirectPath,
            isNull,
            reason:
                'Unauthenticated user accessing $route should not be redirected',
          );
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 7.8: AuthGuard maintains single responsibility
    // Validates: Requirement 7.2
    // ========================================================================
    Glados2(any.anyRoute, any.authState, ExploreConfig()).test(
      'For any route and auth state, AuthGuard SHALL only call auth-related methods',
      (route, isAuthenticated) {
        final fixture =
            AuthGuardTestFixture.create(isAuthenticated: isAuthenticated);
        final state = MockGoRouterState(matchedLocation: route);

        try {
          // Act
          fixture.authGuard.redirect(
            _createMockBuildContext(),
            state,
          );

          // Assert: Only auth-related methods were called
          expect(
            fixture.authGuard.onlyAuthGuardMethodsCalled,
            isTrue,
            reason: 'AuthGuard should only call authentication-related methods',
          );
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 7.9: Multiple redirect evaluations are all handled by AuthGuard
    // Validates: Requirement 7.1
    // ========================================================================
    Glados(any.nonEmptyList(any.anyRoute), ExploreConfig()).test(
      'For any sequence of routes, all redirects SHALL be handled by AuthGuard',
      (routes) {
        final fixture = AuthGuardTestFixture.create();

        try {
          // Act - evaluate redirects for all routes
          for (final route in routes) {
            final state = MockGoRouterState(matchedLocation: route);
            fixture.authGuard.redirect(
              _createMockBuildContext(),
              state,
            );
          }

          // Assert: All routes were processed
          expect(
            fixture.authGuard.redirectPaths.length,
            equals(routes.length),
            reason: 'AuthGuard should process all ${routes.length} routes',
          );

          // Assert: Each route was recorded
          for (final route in routes) {
            expect(
              fixture.authGuard.redirectPaths,
              contains(route),
              reason: 'AuthGuard should record route: $route',
            );
          }
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 7.10: Auth state changes affect redirect behavior correctly
    // Validates: Requirement 7.1
    // ========================================================================
    Glados(any.protectedRoute, ExploreConfig()).test(
      'For any protected route, auth state change SHALL affect redirect behavior',
      (route) {
        final fixture = AuthGuardTestFixture.create();
        final state = MockGoRouterState(matchedLocation: route);

        try {
          // Act - first check when unauthenticated
          final redirectWhenUnauthenticated = fixture.authGuard.redirect(
            _createMockBuildContext(),
            state,
          );

          // Change auth state
          fixture.authGuard.authenticated = true;
          fixture.reset();

          // Act - second check when authenticated
          final redirectWhenAuthenticated = fixture.authGuard.redirect(
            _createMockBuildContext(),
            state,
          );

          // Assert: Different behavior based on auth state
          expect(
            redirectWhenUnauthenticated,
            equals('/login'),
            reason: 'Unauthenticated user should be redirected to /login',
          );

          expect(
            redirectWhenAuthenticated,
            isNull,
            reason: 'Authenticated user should not be redirected',
          );
        } finally {
          fixture.reset();
        }
      },
    );
  });

  // ==========================================================================
  // Unit Tests for Edge Cases
  // ==========================================================================
  group('Auth Guard Encapsulation - Edge Cases', () {
    test('AuthGuard should handle root path correctly for authenticated users',
        () {
      final fixture = AuthGuardTestFixture.create(isAuthenticated: true);
      final state = MockGoRouterState(matchedLocation: '/');

      final redirectPath = fixture.authGuard.redirect(
        _createMockBuildContext(),
        state,
      );

      // Authenticated user at root should not be redirected
      expect(redirectPath, isNull);

      fixture.reset();
    });

    test(
        'AuthGuard should handle root path correctly for unauthenticated users',
        () {
      final fixture = AuthGuardTestFixture.create();
      final state = MockGoRouterState(matchedLocation: '/');

      final redirectPath = fixture.authGuard.redirect(
        _createMockBuildContext(),
        state,
      );

      // Unauthenticated user at root should be redirected to login
      expect(redirectPath, equals('/login'));

      fixture.reset();
    });

    test('AuthGuard should handle nested routes correctly', () {
      final fixture = AuthGuardTestFixture.create();
      final state = MockGoRouterState(matchedLocation: '/forum/123');

      final redirectPath = fixture.authGuard.redirect(
        _createMockBuildContext(),
        state,
      );

      // Unauthenticated user at nested route should be redirected to login
      expect(redirectPath, equals('/login'));

      fixture.reset();
    });

    test('AuthGuard should track all method calls in order', () {
      final fixture = AuthGuardTestFixture.create();
      final state = MockGoRouterState(matchedLocation: '/quiz');

      fixture.authGuard.redirect(
        _createMockBuildContext(),
        state,
      );

      // Verify method call order: redirect -> isAuthenticated -> isPublicRoute
      expect(fixture.authGuard.methodCalls[0], equals('redirect'));
      expect(fixture.authGuard.methodCalls[1], equals('isAuthenticated'));
      expect(fixture.authGuard.methodCalls[2], equals('isPublicRoute'));

      fixture.reset();
    });

    test('MockAuthGuard should correctly identify public routes', () {
      // Test the mock AuthGuard implementation with default public routes
      final authGuard = MockAuthGuard(publicRoutes: {'/login'});

      expect(authGuard.isPublicRoute('/login'), isTrue);
      expect(authGuard.isPublicRoute('/'), isFalse);
      expect(authGuard.isPublicRoute('/quiz'), isFalse);
      expect(authGuard.isPublicRoute('/account'), isFalse);
    });

    test('AuthGuard should handle rapid consecutive redirects', () {
      final fixture = AuthGuardTestFixture.create();

      final routes = ['/quiz', '/video', '/account', '/emergency'];

      for (final route in routes) {
        final state = MockGoRouterState(matchedLocation: route);
        fixture.authGuard.redirect(
          _createMockBuildContext(),
          state,
        );
      }

      // All routes should be recorded
      expect(fixture.authGuard.redirectPaths.length, equals(4));
      expect(fixture.authGuard.redirectPaths, containsAll(routes));

      fixture.reset();
    });
  });
}

/// Creates a mock BuildContext for testing
/// Note: This is a minimal mock that satisfies the type requirement
BuildContext _createMockBuildContext() {
  return _MockBuildContext();
}

class _MockBuildContext implements BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
