# Backend Abstraction Layer

This module provides a complete abstraction over backend services following the **Hexagonal Architecture (Ports & Adapters)** pattern.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      APPLICATION CORE                          │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                   Domain Layer                           │   │
│  │  • Entities (User, Forum, Consent, etc.)                │   │
│  │  • Use Cases / Business Logic                           │   │
│  │  • Repositories (abstractions)                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                           │                                     │
│                           ▼                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                   PORTS (Interfaces)                     │   │
│  │  • IAuthService      - Authentication operations        │   │
│  │  • IDataStore        - Database CRUD & queries          │   │
│  │  • IStorageService   - File storage operations          │   │
│  │  • IAnalyticsService - Event tracking                   │   │
│  │  • IRealtimeService  - Real-time subscriptions          │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                   ADAPTERS (Implementations)                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │   Firebase   │  │   Supabase   │  │   Appwrite   │         │
│  │   Adapter    │  │   Adapter    │  │   Adapter    │         │
│  │  (Current)   │  │  (Future)    │  │  (Future)    │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
└─────────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
lib/core/backend/
├── backend.dart              # Barrel file (exports all)
├── backend_factory.dart      # Factory for creating services
│
├── models/                   # Backend-agnostic models
│   ├── backend_result.dart   # Type-safe result wrapper
│   ├── backend_user.dart     # Universal user model
│   └── query_options.dart    # Query filters & options
│
├── ports/                    # Interfaces (contracts)
│   ├── auth_service_port.dart
│   ├── data_store_port.dart
│   ├── storage_service_port.dart
│   ├── analytics_service_port.dart
│   └── realtime_service_port.dart
│
└── adapters/                 # Implementations
    └── firebase/
        ├── firebase_auth_adapter.dart
        ├── firebase_data_store_adapter.dart
        ├── firebase_storage_adapter.dart
        └── firebase_analytics_adapter.dart
```

## SOLID Principles Applied

| Principle | Application |
|-----------|-------------|
| **SRP** | Each port has a single responsibility (auth, data, storage, etc.) |
| **OCP** | Add new providers without modifying existing code |
| **LSP** | Any adapter can substitute for its port interface |
| **ISP** | Ports are segregated by concern, not combined |
| **DIP** | Application depends on port interfaces, not concrete implementations |

## Usage Examples

### 1. Setup in Dependency Injection

```dart
// lib/core/di/injection.dart
import 'package:guardiancare/core/backend/backend.dart';

void setupBackendServices(GetIt sl) {
  // Choose your backend provider
  const factory = BackendFactory(BackendProvider.firebase);

  // Register services
  sl.registerLazySingleton<IAuthService>(() => factory.createAuthService());
  sl.registerLazySingleton<IDataStore>(() => factory.createDataStore());
  sl.registerLazySingleton<IStorageService>(() => factory.createStorageService());
  sl.registerLazySingleton<IAnalyticsService>(() => factory.createAnalyticsService());
}
```

### 2. Using in Repositories

```dart
// lib/features/forum/data/repositories/forum_repository.dart
class ForumRepositoryImpl implements ForumRepository {
  final IDataStore dataStore;

  ForumRepositoryImpl(this.dataStore);

  @override
  Future<Either<Failure, List<Forum>>> getForums() async {
    final result = await dataStore.query(
      'forum',
      options: QueryOptions(
        orderBy: [OrderBy('createdAt', descending: true)],
        limit: 20,
      ),
    );

    return result.when(
      success: (data) => Right(data.map(Forum.fromJson).toList()),
      failure: (error) => Left(ServerFailure(error.message)),
    );
  }
}
```

### 3. Using in BLoCs

```dart
// lib/features/auth/presentation/bloc/auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthService authService;

  AuthBloc(this.authService) : super(AuthInitial()) {
    on<SignInRequested>(_onSignIn);
  }

  Future<void> _onSignIn(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authService.signInWithEmail(
      email: event.email,
      password: event.password,
    );

    result.when(
      success: (user) => emit(Authenticated(user)),
      failure: (error) => emit(AuthError(error.message)),
    );
  }
}
```

### 4. Type-Safe Results

```dart
// Using BackendResult
final result = await dataStore.get('users', userId);

// Pattern matching
result.when(
  success: (data) {
    if (data != null) {
      final user = User.fromJson(data);
      print('Found user: ${user.name}');
    } else {
      print('User not found');
    }
  },
  failure: (error) {
    print('Error: ${error.message}');
    // Handle specific error codes
    if (error.code == BackendErrorCode.permissionDenied) {
      // Show permission error
    }
  },
);

// Or use convenience methods
final user = result.getOrElse({'name': 'Guest'});
final maybeUser = result.dataOrNull;
```

### 5. Querying Data

```dart
// Build queries with fluent API
final options = QueryOptions()
    .where('status', FilterOperator.equals, 'active')
    .where('age', FilterOperator.greaterThan, 18)
    .order('createdAt', descending: true)
    .take(20);

final result = await dataStore.query('users', options: options);

// Or use pre-built filters
final options = QueryOptions(
  filters: [
    QueryFilter.equals('category', 'parent'),
    QueryFilter.greaterThan('votes', 10),
  ],
  orderBy: [OrderBy('createdAt', descending: true)],
  limit: 50,
);
```

## Switching Backend Providers

### Current: Firebase

```dart
const factory = BackendFactory(BackendProvider.firebase);
```

### Future: Supabase

1. Create adapter implementations:
```dart
// lib/core/backend/adapters/supabase/supabase_auth_adapter.dart
class SupabaseAuthAdapter implements IAuthService {
  final SupabaseClient _client;

  @override
  Future<BackendResult<BackendUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    // Map to BackendUser...
  }
}
```

2. Update the factory:
```dart
const factory = BackendFactory(BackendProvider.supabase);
```

3. **No changes needed in repositories, BLoCs, or UI!**

## Testing

### Mock Adapters

```dart
class MockDataStore implements IDataStore {
  final Map<String, Map<String, dynamic>> _data = {};

  @override
  Future<BackendResult<Map<String, dynamic>?>> get(
    String collection,
    String documentId,
  ) async {
    final key = '$collection/$documentId';
    return BackendResult.success(_data[key]);
  }

  // ... other methods
}

// In tests
final mockDataStore = MockDataStore();
final repository = ForumRepositoryImpl(mockDataStore);
```

### Using Mocktail

```dart
class MockAuthService extends Mock implements IAuthService {}

void main() {
  late MockAuthService mockAuth;
  late AuthBloc bloc;

  setUp(() {
    mockAuth = MockAuthService();
    bloc = AuthBloc(mockAuth);
  });

  test('emits Authenticated on successful login', () {
    when(() => mockAuth.signInWithEmail(
      email: any(named: 'email'),
      password: any(named: 'password'),
    )).thenAnswer((_) async => BackendResult.success(
      BackendUser(id: '123', email: 'test@test.com'),
    ));

    // Test...
  });
}
```

## Benefits

| Benefit | Description |
|---------|-------------|
| **Backend Agnostic** | Switch providers without changing business logic |
| **Testable** | Easy to mock for unit tests |
| **Maintainable** | Clear separation of concerns |
| **Scalable** | Add new providers without modifying existing code |
| **Type-Safe** | Compile-time checks with sealed classes |
| **Consistent API** | Same interface regardless of backend |

## Migration Path

To migrate existing code to use the abstraction layer:

1. **Replace direct Firestore calls** with `IDataStore` methods
2. **Replace direct FirebaseAuth calls** with `IAuthService` methods
3. **Inject interfaces** instead of concrete Firebase instances
4. **Use BackendResult** instead of try-catch for error handling

### Before

```dart
// Direct Firebase usage
final doc = await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .get();
if (doc.exists) {
  return User.fromJson(doc.data()!);
}
throw NotFoundException('User not found');
```

### After

```dart
// Using abstraction
final result = await dataStore.get('users', userId);
return result.when(
  success: (data) => data != null 
    ? User.fromJson(data) 
    : throw NotFoundException('User not found'),
  failure: (error) => throw error.toException(),
);
```
