import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:guardiancare/core/models/auth_state_event.dart';

/// Abstract interface for authentication state management
/// Follows Single Responsibility Principle - only manages auth state
abstract class AuthStateManager {
  /// Stream of Firebase auth state changes
  Stream<User?> get authStateChanges;

  /// Stream of auth state events for dependent services
  Stream<AuthStateEvent> get authEvents;

  /// Current authenticated user
  User? get currentUser;

  /// Notify dependent services about logout
  void notifyLogout();

  /// Dispose resources
  void dispose();
}

/// Implementation of AuthStateManager
/// Manages authentication state and notifies dependent services through events
class AuthStateManagerImpl implements AuthStateManager {
  final FirebaseAuth _auth;
  final StreamController<AuthStateEvent> _eventController =
      StreamController<AuthStateEvent>.broadcast();

  StreamSubscription<User?>? _authSubscription;
  User? _currentUser;

  AuthStateManagerImpl({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance {
    _init();
  }

  void _init() {
    _currentUser = _auth.currentUser;
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
    debugPrint('AuthStateManager initialized. Current user: ${_currentUser?.uid}');
  }

  void _onAuthStateChanged(User? user) {
    final previousUser = _currentUser;
    _currentUser = user;

    if (user != null && previousUser == null) {
      // User logged in
      _eventController.add(AuthStateEvent.login(user));
      debugPrint('AuthStateManager: User logged in - ${user.uid}');
    } else if (user == null && previousUser != null) {
      // User logged out
      _eventController.add(AuthStateEvent.logout());
      debugPrint('AuthStateManager: User logged out');
    }
  }

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Stream<AuthStateEvent> get authEvents => _eventController.stream;

  @override
  User? get currentUser => _currentUser;

  @override
  void notifyLogout() {
    _eventController.add(AuthStateEvent.logout());
    debugPrint('AuthStateManager: Logout notification sent');
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _eventController.close();
    debugPrint('AuthStateManager disposed');
  }
}
