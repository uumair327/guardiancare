# Core Configuration Module

This module provides centralized configuration following Clean Architecture and SOLID principles.

## Architecture Overview

```
lib/core/config/
├── config.dart              # Barrel file (exports all)
├── app_config.dart          # Application-level configuration (SRP)
├── api_endpoints.dart       # External API endpoints (OCP)
├── environment_config.dart  # Environment-specific config (DIP)
├── firebase_config.dart     # Firebase collections & fields (ISP)
└── network_config.dart      # Network/HTTP configuration (SRP)
```

## SOLID Principles Applied

### Single Responsibility Principle (SRP)
Each config file has one reason to change:
- `app_config.dart` - App-level settings only
- `network_config.dart` - Network/HTTP settings only
- `firebase_config.dart` - Firebase structure only

### Open/Closed Principle (OCP)
`api_endpoints.dart` is open for extension (add new API services) but closed for modification (existing endpoints don't change).

### Liskov Substitution Principle (LSP)
`ApiClient` interface allows swapping implementations without breaking consumers.

### Interface Segregation Principle (ISP)
Configuration is split into focused classes instead of one monolithic config.

### Dependency Inversion Principle (DIP)
`environment_config.dart` provides abstraction over environment-specific values.

## Usage Examples

### Import Configuration
```dart
import 'package:guardiancare/core/config/config.dart';
```

### App Configuration
```dart
// App metadata
print(AppConfig.appName);           // "GuardianCare"
print(AppConfig.appVersion);        // "1.0.0"

// Timeouts
final timeout = Duration(seconds: AppConfig.connectionTimeout);

// Feature flags
if (AppConfig.analyticsEnabled) {
  await Analytics.initialize();
}
```

### Firebase Collections
```dart
// Use collection names
final usersRef = firestore.collection(FirebaseConfig.collections.users);
final forumRef = firestore.collection(FirebaseConfig.collections.forum);

// Use field names
final query = usersRef.where(
  FirebaseConfig.fields.role,
  isEqualTo: 'parent',
);

// Use path helpers
final commentPath = FirebaseConfig.paths.commentDoc('forum123', 'comment456');
```

### API Endpoints
```dart
// YouTube API
final searchUrl = ApiEndpoints.youtube.searchVideos(
  query: 'child safety',
  apiKey: apiKey,
  maxResults: 10,
);

final thumbnailUrl = ApiEndpoints.youtube.thumbnailUrl(
  'VIDEO_ID',
  quality: ThumbnailQuality.high,
);

// External URLs
final privacy = ApiEndpoints.external.privacyPolicy;
final support = ApiEndpoints.external.supportEmail;
```

### Network Configuration
```dart
// HTTP headers
final headers = {
  NetworkConfig.headerContentType: NetworkConfig.contentTypeJson,
  NetworkConfig.headerAuthorization: '${NetworkConfig.bearerPrefix}$token',
};

// Status code checking
if (NetworkConfig.isSuccess(response.statusCode)) {
  // Handle success
}

if (NetworkConfig.shouldRetry(response.statusCode)) {
  // Retry the request
}
```

### Environment Configuration
```dart
// Initialize in main.dart
void main() async {
  EnvironmentConfig.initialize();
  
  if (EnvironmentConfig.current.enableAnalytics) {
    await Analytics.initialize();
  }
  
  runApp(const MyApp());
}

// Check environment
if (EnvironmentConfig.isDevelopment) {
  print('Running in development mode');
}

// Use environment-specific values
final projectId = EnvironmentConfig.current.firebaseProjectId;
```

### API Client
```dart
// Create client
final client = HttpApiClient();

// Make requests with automatic retry
final response = await client.get(
  ApiEndpoints.youtube.search,
  queryParameters: {'q': 'safety tips'},
);

// Parse response
if (response.isSuccess) {
  final data = response.jsonMap;
  // Process data
}

// Don't forget to dispose
client.dispose();
```

## Environment Setup

### Build with Environment
```bash
# Development
flutter run --dart-define=ENV=dev

# Staging
flutter run --dart-define=ENV=staging

# Production (default)
flutter run --dart-define=ENV=prod
```

## Migration Guide

### Before (Hardcoded)
```dart
// ❌ Avoid
final users = firestore.collection('users');
final timeout = Duration(seconds: 30);
```

### After (Centralized)
```dart
// ✅ Preferred
final users = firestore.collection(FirebaseConfig.collections.users);
final timeout = Duration(seconds: NetworkConfig.connectionTimeout);
```

## Benefits

1. **Single Source of Truth** - All config values in one place
2. **Type Safety** - Compile-time checks for all values
3. **Easy Refactoring** - Change collection name once, updates everywhere
4. **Environment Support** - Easy switching between dev/staging/prod
5. **Documentation** - Self-documenting code with clear structure
6. **Testing** - Easy to mock and override for tests
