import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/backend/backend.dart';

/// Encapsulates all authentication redirect logic for the router.
///
/// This class follows the Single Responsibility Principle by handling
/// only authentication-related routing decisions.
///
/// This class follows the Dependency Inversion Principle by depending
/// on the IAuthService abstraction, not Firebase directly.
abstract class AuthGuard {
  /// Determines if a redirect is needed based on authentication state.
  /// Returns the redirect path or null if no redirect is needed.
  String? redirect(BuildContext context, GoRouterState state);

  /// Checks if the current user is authenticated.
  bool isAuthenticated();

  /// Checks if the given path is a public route that doesn't require authentication.
  bool isPublicRoute(String path);
}

/// Implementation of AuthGuard using IAuthService abstraction.
///
/// This implementation is backend-agnostic and works with any
/// authentication provider that implements IAuthService.
///
/// Following: DIP (Dependency Inversion Principle)
class AuthGuardImpl implements AuthGuard {
  final IAuthService _authService;

  /// List of routes that don't require authentication
  static const List<String> _publicRoutes = [
    '/login',
    // Email/Password routes commented out - only Google Sign-In enabled
    // '/signup',
    // '/password-reset',
    // '/email-verification',
  ];

  AuthGuardImpl({required IAuthService authService})
      : _authService = authService;

  @override
  String? redirect(BuildContext context, GoRouterState state) {
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
    return _authService.isSignedIn;
  }

  @override
  bool isPublicRoute(String path) {
    return _publicRoutes.contains(path);
  }
}

/// Legacy Firebase implementation - kept for backward compatibility
/// @deprecated Use AuthGuardImpl with IAuthService instead
@Deprecated('Use AuthGuardImpl with IAuthService instead')
class FirebaseAuthGuard implements AuthGuard {
  final IAuthService _authService;

  static const List<String> _publicRoutes = [
    '/login',
  ];

  FirebaseAuthGuard({required IAuthService authService})
      : _authService = authService;

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    final isLoggedIn = isAuthenticated();
    final currentPath = state.matchedLocation;
    final isPublic = isPublicRoute(currentPath);

    if (!isLoggedIn && !isPublic) {
      return '/login';
    }

    if (isLoggedIn && isPublic) {
      return '/';
    }

    return null;
  }

  @override
  bool isAuthenticated() {
    return _authService.isSignedIn;
  }

  @override
  bool isPublicRoute(String path) {
    return _publicRoutes.contains(path);
  }
}
