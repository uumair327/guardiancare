# Backend Abstraction Layer

This module provides a complete abstraction over backend services following the **Hexagonal Architecture (Ports & Adapters)** pattern with **Flag-Driven Adapter Resolution**.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      APPLICATION CORE                          │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    Domain Layer                          │   │
│  │  • Business Logic    • Entities    • Use Cases          │   │
│  │  ❌ NO Firebase/Supabase imports here!                  │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │               Application Layer (BLoC/Cubit)            │   │
│  │  • Commands/Queries  • Event Handlers   • State         │   │
│  │  ❌ NO Firebase/Supabase imports here!                  │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                        Dependency Injection
                    (Flag-Driven Resolution)
                              │
┌─────────────────────────────────────────────────────────────────┐
│                      PORTS (Interfaces)                         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  IAuthService │ IDataStore │ IStorage │ IAnalytics │   │   │
│  │               IRealtimeService                          │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     ADAPTERS (Implementations)                   │
│  ┌──────────────────────┐  ┌──────────────────────┐            │
│  │     Firebase         │  │     Supabase         │            │
│  │  ├─ Auth Adapter     │  │  ├─ Auth Adapter     │            │
│  │  ├─ Data Adapter     │  │  ├─ Data Adapter     │            │
│  │  ├─ Storage Adapter  │  │  ├─ Storage Adapter  │            │
│  │  └─ Analytics Adapter│  │  └─ Realtime Adapter │            │
│  └──────────────────────┘  └──────────────────────┘            │
└─────────────────────────────────────────────────────────────────┘
```

## 🔀 Backend Polymorphism via Flag-Driven Adapter Resolution

This pattern enables runtime or build-time backend switching with **zero code changes** to domain/application layers.

### How It Works

```dart
// DI Container - The ONLY place where backend is selected
void _initBackendServices() {
  const factory = BackendFactory(); // Reads from BackendConfig automatically
  
  sl.registerLazySingleton<IAuthService>(() => factory.createAuthService());
  sl.registerLazySingleton<IDataStore>(() => factory.createDataStore());
  sl.registerLazySingleton<IStorageService>(() => factory.createStorageService());
  sl.registerLazySingleton<IAnalyticsService>(() => factory.createAnalyticsService());
}
```

### Switching Backends

#### Option 1: Global Switch (Recommended)

```bash
# Use Firebase (default)
flutter run

# Use Supabase
flutter run --dart-define=BACKEND=supabase
```

#### Option 2: Granular Overrides (Mix & Match)

```bash
# Use Supabase for auth, Firebase for everything else
flutter run --dart-define=USE_SUPABASE_AUTH=true

# Use Supabase for database only
flutter run --dart-define=USE_SUPABASE_DATABASE=true
```

## Directory Structure

```
backend/
├── config/                     # 🔑 Feature Flags & Secrets
│   ├── backend_config.dart     # Flag-driven provider selection
│   └── backend_secrets.dart    # Environment-based secrets
│
├── ports/                      # 📋 Interfaces (Contracts)
│   ├── auth_service_port.dart
│   ├── data_store_port.dart
│   ├── storage_service_port.dart
│   ├── analytics_service_port.dart
│   └── realtime_service_port.dart
│
├── adapters/                   # 🔌 Implementations
│   ├── firebase/
│   │   ├── firebase_auth_adapter.dart
│   │   ├── firebase_data_store_adapter.dart
│   │   ├── firebase_storage_adapter.dart
│   │   └── firebase_analytics_adapter.dart
│   │
│   └── supabase/               # (Skeleton - Phase 2)
│       ├── supabase_auth_adapter.dart
│       ├── supabase_data_store_adapter.dart
│       ├── supabase_storage_adapter.dart
│       └── supabase_realtime_adapter.dart
│
├── models/                     # 📦 Shared Models
│   ├── backend_result.dart     # Type-safe result wrapper
│   ├── backend_user.dart       # Vendor-agnostic user model
│   └── query_options.dart      # Vendor-agnostic query builder
│
├── backend_factory.dart        # 🏭 Factory with flag resolution
└── backend.dart                # 📚 Barrel file (exports)
```

## Quick Start

### 1. Using Backend Services

```dart
// In your repository/service
class UserRepository {
  final IAuthService _auth;
  final IDataStore _dataStore;

  UserRepository({
    required IAuthService auth,
    required IDataStore dataStore,
  })  : _auth = auth,
        _dataStore = dataStore;

  Future<User?> getCurrentUser() async {
    final backendUser = _auth.currentUser;
    if (backendUser == null) return null;
    
    final result = await _dataStore.get('users', backendUser.id);
    return result.when(
      success: (data) => data != null ? User.fromJson(data) : null,
      failure: (error) => null,
    );
  }
}
```

### 2. Type-Safe Error Handling

```dart
final result = await dataStore.get('users', userId);
result.when(
  success: (data) {
    // Handle success
    print('User: ${data?['name']}');
  },
  failure: (error) {
    // Handle error with code
    switch (error.code) {
      case BackendErrorCode.notFound:
        print('User not found');
      case BackendErrorCode.permissionDenied:
        print('Access denied');
      default:
        print('Error: ${error.message}');
    }
  },
);
```

### 3. Stream-based Real-time Updates

```dart
// Both Firebase and Supabase use the same interface
dataStore.streamDocument('users', userId).listen((result) {
  result.when(
    success: (data) => updateUI(data),
    failure: (error) => showError(error),
  );
});
```

## Configuration

### Environment Variables

Set these in your CI/CD or launch configuration:

```bash
# Global backend selection
BACKEND=firebase|supabase

# Granular feature flags
USE_SUPABASE_AUTH=true|false
USE_SUPABASE_DATABASE=true|false
USE_SUPABASE_STORAGE=true|false
USE_SUPABASE_REALTIME=true|false

# Supabase credentials (required if using Supabase)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# Firebase credentials (required if using Firebase)
# Usually provided via google-services.json / GoogleService-Info.plist
```

### Flutter Launch Configuration

```json
// .vscode/launch.json
{
  "configurations": [
    {
      "name": "Dev (Firebase)",
      "request": "launch",
      "type": "dart",
      "args": ["--dart-define=BACKEND=firebase"]
    },
    {
      "name": "Dev (Supabase)",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=BACKEND=supabase",
        "--dart-define=SUPABASE_URL=${env:SUPABASE_URL}",
        "--dart-define=SUPABASE_ANON_KEY=${env:SUPABASE_ANON_KEY}"
      ]
    }
  ]
}
```

## Adding a New Backend

1. **Create Adapter Directory**
   ```
   adapters/appwrite/
   ├── appwrite_auth_adapter.dart
   ├── appwrite_data_store_adapter.dart
   └── ...
   ```

2. **Implement Each Port**
   ```dart
   class AppwriteAuthAdapter implements IAuthService {
     // Implement all interface methods
   }
   ```

3. **Add Provider to Enum**
   ```dart
   enum BackendProvider {
     firebase,
     supabase,
     appwrite,  // ← Add new provider
   }
   ```

4. **Update Backend Factory**
   ```dart
   IAuthService createAuthService() {
     return switch (provider) {
       BackendProvider.firebase => FirebaseAuthAdapter(),
       BackendProvider.supabase => SupabaseAuthAdapter(),
       BackendProvider.appwrite => AppwriteAuthAdapter(),  // ← Add case
     };
   }
   ```

5. **Update BackendConfig**
   ```dart
   static BackendProvider get provider {
     return switch (_backendFlag) {
       'supabase' => BackendProvider.supabase,
       'appwrite' => BackendProvider.appwrite,  // ← Add case
       _ => BackendProvider.firebase,
     };
   }
   ```

## Architecture Rules (NON-NEGOTIABLE)

### ✅ Allowed

- Multiple adapters implementing the same port
- Feature flag evaluation in DI container
- Adapter-level SDK usage
- Parallel backend coexistence
- Backend-specific optimizations in adapters

### ❌ Forbidden

- `if (firebase)` inside use cases
- Backend conditionals inside repositories
- SDK imports in domain layer
- Flag checks in Flutter UI
- Mixed Firebase + Supabase calls in same adapter

## Testing Strategy

```dart
// Unit test with mock backend
class MockAuthService extends Mock implements IAuthService {}

void main() {
  late MockAuthService mockAuth;
  late UserRepository repository;

  setUp(() {
    mockAuth = MockAuthService();
    repository = UserRepository(auth: mockAuth);
  });

  test('returns null when not signed in', () {
    when(() => mockAuth.currentUser).thenReturn(null);
    expect(repository.getCurrentUser(), isNull);
  });
}
```

## Rollback Strategy

If Supabase fails in production:

```bash
# Runtime flag change (if using remote config)
USE_SUPABASE_BACKEND=false

# Or redeploy with Firebase
flutter run --dart-define=BACKEND=firebase
```

**Result**: Firebase resumes instantly, no data migration needed.

## Enterprise Success Criteria

The implementation is correct ONLY IF:

- [x] Firebase & Supabase coexist safely
- [x] Backend switching is config-only
- [x] Domain layer remains untouched
- [x] Flutter app remains unchanged
- [x] No feature duplication exists
- [x] Architecture remains vendor-neutral
