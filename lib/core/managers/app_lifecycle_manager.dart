import 'package:guardiancare/core/services/parental_verification_service.dart';
import 'package:guardiancare/core/util/logger.dart';

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
  AppLifecycleManagerImpl({
    ParentalVerificationService? verificationService,
  }) : _verificationService =
            verificationService ?? ParentalVerificationService() {
    Log.d('AppLifecycleManager initialized');
  }
  final ParentalVerificationService _verificationService;

  @override
  void onPaused() {
    Log.d('AppLifecycleManager: App paused - resetting verification');
    _verificationService.resetVerification();
  }

  @override
  void onDetached() {
    Log.d('AppLifecycleManager: App detached - resetting verification');
    _verificationService.resetVerification();
  }

  @override
  void onResumed() {
    Log.d('AppLifecycleManager: App resumed');
    // Currently no action needed on resume
    // Future: Could refresh session state or check for updates
  }

  @override
  void dispose() {
    Log.d('AppLifecycleManager disposed');
  }
}
