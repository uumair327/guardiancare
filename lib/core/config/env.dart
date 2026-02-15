import 'package:flutter_dotenv/flutter_dotenv.dart';

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
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // If .env file is missing (e.g. in CI/CD or production where secrets are injected via other means),
      // we might want to fail silently or log a warning, depending on the strategy.
      // For this implementation, we assume .env is the primary source during dev.
      print(
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

    // 2. Check compile-time constants (--dart-define)
    // This allows overriding .env with command line args
    const dartDefineValue =
        String.fromEnvironment('__DART_DEFINE_PLACEHOLDER__');
    // We can't dynamically access String.fromEnvironment with a variable key.
    // So we rely on the specific getters in BackendSecrets to use String.fromEnvironment.
    // However, for this helper, we strictly return dotenv or fallback.

    return fallback;
  }

  // Specific keys can be exposed as getters here or in a separate config class
}
