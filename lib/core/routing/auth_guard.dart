import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Encapsulates all authentication redirect logic for the router.
/// 
/// This class follows the Single Responsibility Principle by handling
/// only authentication-related routing decisions.
abstract class AuthGuard {
  /// Determines if a redirect is needed based on authentication state.
  /// Returns the redirect path or null if no redirect is needed.
  String? redirect(BuildContext context, GoRouterState state);
  
  /// Checks if the current user is authenticated.
  bool isAuthenticated();
  
  /// Checks if the given path is a public route that doesn't require authentication.
  bool isPublicRoute(String path);
}

/// Implementation of AuthGuard using Firebase Authentication.
class FirebaseAuthGuard implements AuthGuard {
  final FirebaseAuth _auth;
  
  /// List of routes that don't require authentication
  static const List<String> _publicRoutes = [
    '/login',
    // Email/Password routes commented out - only Google Sign-In enabled
    // '/signup',
    // '/password-reset',
    // '/email-verification',
  ];
  
  FirebaseAuthGuard({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;
  
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
    return _auth.currentUser != null;
  }
  
  @override
  bool isPublicRoute(String path) {
    return _publicRoutes.contains(path);
  }
}
