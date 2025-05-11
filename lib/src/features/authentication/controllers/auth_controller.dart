import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class FirebaseAuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StreamController<User?> _authStateController = StreamController<User?>.broadcast();
  StreamSubscription<User?>? _authSubscription;
  
  @override
  void onInit() {
    super.onInit();
    _authSubscription = _auth.authStateChanges().listen(_authStateController.add);
  }
  
  @override
  void onClose() {
    _authSubscription?.cancel();
    _authStateController.close();
    super.onClose();
  }
  
  User? getCurrentUser() => _auth.currentUser;
  
  Stream<User?> get authStateChanges => _authStateController.stream;
  
  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}

class AuthController extends GetxController {
  final FirebaseAuthService _authService = Get.find<FirebaseAuthService>();
  
  // Reactive user state
  final Rx<User?> _user = Rx<User?>(null);
  bool _isInitialized = false;
  
  User? get user => _user.value;
  Stream<User?> get userStream => _authService.authStateChanges;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _user.value != null && !_user.value!.isAnonymous;
  bool get isGuest => _user.value?.isAnonymous ?? true;
  
  StreamSubscription<User?>? _authSubscription;
  
  @override
  void onInit() {
    super.onInit();
    _initialize();
  }
  
  Future<void> _initialize() async {
    try {
      // Initialize with current user
      _user.value = _authService.getCurrentUser();
      _isInitialized = _user.value != null;
      update();
      
      // Listen for auth state changes
      _authSubscription = _authService.authStateChanges.listen(_handleAuthStateChange);
    } catch (e) {
      debugPrint('Error initializing AuthController: $e');
      _isInitialized = true; // Mark as initialized even if there was an error
      update();
    }
  }
  
  void _handleAuthStateChange(User? user) {
    try {
      final currentUid = _user.value?.uid;
      final newUid = user?.uid;
      
      if (currentUid != newUid) {
        _user.value = user;
        _isInitialized = true;
        update(); // Notify listeners
      } else if (!_isInitialized) {
        _isInitialized = true;
        update();
      }
    } catch (e) {
      debugPrint('Error handling auth state change: $e');
    }
  }
  
  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  @override
  void onReady() {
    super.onReady();
    // Any post-initialization logic can go here
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      await _authService._auth.signInWithCredential(credential);
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign in with Google');
    }
  }

  // Sign in as guest
  Future<void> signInAsGuest() async {
    try {
      await _authService.signInAnonymously();
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign in as guest');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Check if current route requires authentication
  bool requiresAuth(String routeName) {
    // Add routes that don't require authentication
    final publicRoutes = [
      '/login',
      '/forgot-password',
      '/signup',
    ];
    
    return !publicRoutes.contains(routeName);
  }

  // Check if current route requires full account (not guest)
  bool requiresFullAccount(String routeName) {
    // Add routes that require full account
    final restrictedRoutes = [
      '/parental-controls',
      '/account',
      '/settings',
    ];
    
    return restrictedRoutes.contains(routeName);
  }
}
