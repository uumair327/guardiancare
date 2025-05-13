import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth_service.dart';
import '../exceptions/auth_exception.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  // Reactive user state
  final Rx<User?> _user = Rx<User?>(null);
  final RxBool _isInitialized = false.obs;
  final RxBool _isLoading = true.obs;
  
  User? get user => _user.value;
  bool get isInitialized => _isInitialized.value;
  bool get isAuthenticated => _user.value != null && !_user.value!.isAnonymous;
  bool get isGuest => _user.value?.isAnonymous ?? true;
  bool get isLoading => _isLoading.value;
  
  StreamSubscription<User?>? _authSubscription;
  
  @override
  void onInit() {
    super.onInit();
    
    // Initialize with current user first
    _initializeUser();
    _listenForAuthStateChanges();
  }

  void _initializeUser() {
    _user.value = _authService.getCurrentUser();
    _isInitialized.value = true;
    _isLoading.value = false;
  }

  void _listenForAuthStateChanges() {
    _authSubscription = _authService.authStateChanges.listen(
      _handleAuthStateChange,
      onError: (error) {
        developer.log('Error in auth state stream', error: error);
        Get.snackbar(
          'Error',
          'An error occurred while updating authentication state',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
    );
  }

  void _handleAuthStateChange(User? user) {
    try {
      final currentUid = _user.value?.uid;
      final newUid = user?.uid;

      // Only update if the user has changed
      if (currentUid != newUid) {
        _user.value = user;
        _isInitialized.value = true;
        _isLoading.value = false;
      }
    } catch (e) {
      developer.log('Error in auth state change', error: e);
      // Don't throw here as it would break the stream
    }
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  // Get the user stream
  Stream<User?> get userStream => _authService.authStateChanges;

  // Authentication methods
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      Get.offAllNamed('/home');
    } catch (e) {
      debugPrint('Error signing in with email: $e');
      rethrow;
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      Get.offAllNamed('/home');
    } catch (e) {
      debugPrint('Error signing up with email: $e');
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _authService.signInWithGoogle();
      Get.offAllNamed('/home');
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      Get.snackbar(
        'Success',
        'Password reset email sent',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  Future<void> signInAsGuest() async {
    try {
      await _authService.signInAnonymously();
      Get.offAllNamed('/home');
    } catch (e) {
      debugPrint('Error signing in as guest: $e');
      rethrow;
    }
  }
}

// Check if current route requires authentication
bool requiresAuth(String routeName) {
  // Add routes that require authentication
  final authRequiredRoutes = [
    '/profile',
    '/settings',
    '/home',
  ];
  return authRequiredRoutes.any((route) => routeName.startsWith(route));
}

// Check if current route requires full account (not guest)
bool requiresFullAccount(String routeName) {
  // Add routes that require a full account (not guest)
  final fullAccountRequiredRoutes = [
    '/profile/edit',
    '/settings/account',
  ];
  return fullAccountRequiredRoutes.any((route) => routeName.startsWith(route));
}
