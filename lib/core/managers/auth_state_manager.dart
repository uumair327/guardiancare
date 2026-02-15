import 'dart:async';

import 'package:guardiancare/core/backend/backend.dart';
import 'package:guardiancare/core/models/auth_state_event.dart';
import 'package:guardiancare/core/util/logger.dart';

/// Abstract interface for authentication state management
/// Follows Single Responsibility Principle - only manages auth state
/// Follows Dependency Inversion Principle - depends on IAuthService abstraction
abstract class AuthStateManager {
  /// Stream of authentication state changes
  Stream<BackendUser?> get authStateChanges;

  /// Stream of auth state events for dependent services
  Stream<AuthStateEvent> get authEvents;

  /// Current authenticated user
  BackendUser? get currentUser;

  /// Notify dependent services about logout
  void notifyLogout();

  /// Dispose resources
  void dispose();
}

/// Implementation of AuthStateManager using IAuthService abstraction
///
/// This implementation is backend-agnostic and works with any
/// authentication provider that implements IAuthService.
///
/// Following: DIP (Dependency Inversion Principle)
class AuthStateManagerImpl implements AuthStateManager {
  AuthStateManagerImpl({required IAuthService authService})
      : _authService = authService {
    _init();
  }
  final IAuthService _authService;
  final StreamController<AuthStateEvent> _eventController =
      StreamController<AuthStateEvent>.broadcast();

  StreamSubscription<BackendUser?>? _authSubscription;
  BackendUser? _currentUser;

  void _init() {
    _currentUser = _authService.currentUser;
    _authSubscription =
        _authService.authStateChanges.listen(_onAuthStateChanged);
    Log.d('AuthStateManager initialized. Current user: ${_currentUser?.id}');
  }

  void _onAuthStateChanged(BackendUser? user) {
    final previousUser = _currentUser;
    _currentUser = user;

    if (user != null && previousUser == null) {
      // User logged in
      _eventController.add(AuthStateEvent.loginFromBackendUser(user));
      Log.d('AuthStateManager: User logged in - ${user.id}');
    } else if (user == null && previousUser != null) {
      // User logged out
      _eventController.add(AuthStateEvent.logout());
      Log.d('AuthStateManager: User logged out');
    }
  }

  @override
  Stream<BackendUser?> get authStateChanges => _authService.authStateChanges;

  @override
  Stream<AuthStateEvent> get authEvents => _eventController.stream;

  @override
  BackendUser? get currentUser => _currentUser;

  @override
  void notifyLogout() {
    _eventController.add(AuthStateEvent.logout());
    Log.d('AuthStateManager: Logout notification sent');
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _eventController.close();
    Log.d('AuthStateManager disposed');
  }
}
