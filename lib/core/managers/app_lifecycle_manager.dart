import 'package:flutter/foundation.dart' show debugPrint;
import 'package:guardiancare/core/services/parental_verification_service.dart';

/// Abstract interface for app lifecycle management
/// Follows Single Responsibility Principle - only manages lifecycle events
abstract class AppLifecycleManager {
  /// Called when app is paused (moved to background)
  void onPaused();

  /// Called when app is detached (being terminated)
  void onDetached();

  /// Called when app is resumed (brought to foreground)
  void onResumed();

  /// Dispose resources
  void dispose();
}

/// Implementation of AppLifecycleManager
/// Manages app lifecycle events and delegates to appropriate services
class AppLifecycleManagerImpl implements AppLifecycleManager {
  final ParentalVerificationService _verificationService;

  AppLifecycleManagerImpl({
    ParentalVerificationService? verificationService,
  }) : _verificationService = verificationService ?? ParentalVerificationService() {
    debugPrint('AppLifecycleManager initialized');
  }

  @override
  void onPaused() {
    debugPrint('AppLifecycleManager: App paused - resetting verification');
    _verificationService.resetVerification();
  }

  @override
  void onDetached() {
    debugPrint('AppLifecycleManager: App detached - resetting verification');
    _verificationService.resetVerification();
  }

  @override
  void onResumed() {
    debugPrint('AppLifecycleManager: App resumed');
    // Currently no action needed on resume
    // Future: Could refresh session state or check for updates
  }

  @override
  void dispose() {
    debugPrint('AppLifecycleManager disposed');
  }
}
