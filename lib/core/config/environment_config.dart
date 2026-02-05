/// Environment configuration for different app flavors.
///
/// This class follows the Dependency Inversion Principle (DIP) by providing
/// an abstraction for environment-specific configuration.
///
/// ## Environment Detection
/// The environment is determined by:
/// 1. Compile-time constant `--dart-define=ENV=dev`
/// 2. Default fallback to production
///
/// ## Usage
/// ```dart
/// // In main.dart
/// await EnvironmentConfig.initialize();
///
/// // Access configuration
/// if (EnvironmentConfig.current.enableAnalytics) {
///   await Analytics.initialize();
/// }
/// ```
abstract final class EnvironmentConfig {
  EnvironmentConfig._();

  /// Current environment name from compile-time constant
  static const String _envName = String.fromEnvironment(
    'ENV',
    defaultValue: 'prod',
  );

  /// Current environment configuration
  static late final Environment current;

  /// Initialize environment configuration
  static void initialize() {
    current = switch (_envName.toLowerCase()) {
      'dev' || 'development' => Environment.development,
      'staging' || 'stage' => Environment.staging,
      'prod' || 'production' => Environment.production,
      _ => Environment.production,
    };
  }

  /// Check if current environment is development
  static bool get isDevelopment => current == Environment.development;

  /// Check if current environment is staging
  static bool get isStaging => current == Environment.staging;

  /// Check if current environment is production
  static bool get isProduction => current == Environment.production;
}

/// Environment configurations.
enum Environment {
  development(
    name: 'Development',
    firebaseProjectId: 'guardiancare-dev',
    enableAnalytics: false,
    enableCrashReporting: false,
    enablePerformanceMonitoring: false,
    enableDebugBanner: true,
    logLevel: LogLevel.verbose,
    cacheEnabled: false,
  ),
  staging(
    name: 'Staging',
    firebaseProjectId: 'guardiancare-staging',
    enableAnalytics: true,
    enableCrashReporting: true,
    enablePerformanceMonitoring: true,
    enableDebugBanner: true,
    logLevel: LogLevel.debug,
    cacheEnabled: true,
  ),
  production(
    name: 'Production',
    firebaseProjectId: 'guardiancare-prod',
    enableAnalytics: true,
    enableCrashReporting: true,
    enablePerformanceMonitoring: true,
    enableDebugBanner: false,
    logLevel: LogLevel.warning,
    cacheEnabled: true,
  );

  const Environment({
    required this.name,
    required this.firebaseProjectId,
    required this.enableAnalytics,
    required this.enableCrashReporting,
    required this.enablePerformanceMonitoring,
    required this.enableDebugBanner,
    required this.logLevel,
    required this.cacheEnabled,
  });

  /// Display name for the environment
  final String name;

  /// Firebase project ID for this environment
  final String firebaseProjectId;

  /// Whether analytics should be enabled
  final bool enableAnalytics;

  /// Whether crash reporting should be enabled
  final bool enableCrashReporting;

  /// Whether performance monitoring should be enabled
  final bool enablePerformanceMonitoring;

  /// Whether to show debug banner
  final bool enableDebugBanner;

  /// Minimum log level for this environment
  final LogLevel logLevel;

  /// Whether caching is enabled
  final bool cacheEnabled;
}

/// Log level enumeration.
enum LogLevel {
  verbose(0),
  debug(1),
  info(2),
  warning(3),
  error(4),
  none(5);

  const LogLevel(this.priority);

  /// Priority value (lower = more verbose)
  final int priority;

  /// Check if this level should be logged based on minimum level
  bool shouldLog(LogLevel minimumLevel) => priority >= minimumLevel.priority;
}
