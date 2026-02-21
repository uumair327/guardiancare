import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:guardiancare/core/util/logger.dart';

/// Environment configuration using .env files.
///
/// This class handles loading and accessing environment variables.
class Env {
  Env._();

  /// Initialize environment configuration
  ///
  /// Loads the appropriate .env file based on the environment.
  /// Defaults to .env if no specific environment is set.
  static Future<void> init() async {
    // Determine which file to load based on compile-time constants or other logic
    // For now, we load the main .env file.
    // In a more complex setup, we could check kReleaseMode or --dart-define=ENV
    try {
      await dotenv.load();
    } on Object {
      // If .env file is missing (e.g. in CI/CD or production where secrets are injected via other means),
      // we might want to fail silently or log a warning, depending on the strategy.

      // For this implementation, we assume .env is the primary source during dev.
      Log.w(
          'Warning: .env file not found. Ensure environment variables are set.');
    }
  }

  /// Get value from environment
  ///
  /// Tries to get from .env file first, then falls back to Platform.environment (if supported),
  /// then to String.fromEnvironment (compile-time constant).
  static String get(String key, {String fallback = ''}) {
    // 1. Check .env file (runtime)
    final dotenvValue = dotenv.env[key];
    if (dotenvValue != null && dotenvValue.isNotEmpty) {
      return dotenvValue;
    }

    // Note: String.fromEnvironment cannot be called with a dynamic key.
    // Compile-time constants are accessed via specific getters (e.g. BackendSecrets).

    return fallback;
  }

  // Specific keys can be exposed as getters here or in a separate config class
}
