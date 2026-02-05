/// Backend Services Abstraction Layer
///
/// This module provides a complete abstraction over backend services following
/// the Hexagonal Architecture (Ports & Adapters) pattern.
///
/// ## Architecture
/// ```
/// ┌─────────────────────────────────────────────────────────────────┐
/// │                      APPLICATION CORE                          │
/// │  ┌─────────────────────────────────────────────────────────┐   │
/// │  │                   Domain Layer                           │   │
/// │  │  • Entities (User, Forum, Consent, etc.)                │   │
/// │  │  • Use Cases / Business Logic                           │   │
/// │  └─────────────────────────────────────────────────────────┘   │
/// │                           │                                     │
/// │                           ▼                                     │
/// │  ┌─────────────────────────────────────────────────────────┐   │
/// │  │                   PORTS (Interfaces)                     │   │
/// │  │  • IAuthService                                         │   │
/// │  │  • IDataStore                                           │   │
/// │  │  • IStorageService                                      │   │
/// │  │  • IAnalyticsService                                    │   │
/// │  └─────────────────────────────────────────────────────────┘   │
/// └─────────────────────────────────────────────────────────────────┘
///                             │
///                             ▼
/// ┌─────────────────────────────────────────────────────────────────┐
/// │                   ADAPTERS (Implementations)                    │
/// │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
/// │  │   Firebase   │  │   Supabase   │  │    Custom    │         │
/// │  │   Adapter    │  │   Adapter    │  │    Backend   │         │
/// │  └──────────────┘  └──────────────┘  └──────────────┘         │
/// └─────────────────────────────────────────────────────────────────┘
/// ```
///
/// ## Benefits
/// 1. **Backend Agnostic** - Switch providers without changing business logic
/// 2. **Testable** - Easy to mock for unit tests
/// 3. **Maintainable** - Clear separation of concerns
/// 4. **Scalable** - Add new providers without modifying existing code
///
/// ## Usage
/// ```dart
/// // In dependency injection
/// sl.registerLazySingleton<IAuthService>(() => FirebaseAuthAdapter());
///
/// // Later, to switch to Supabase:
/// sl.registerLazySingleton<IAuthService>(() => SupabaseAuthAdapter());
/// ```
library backend;

// Core abstractions (Ports)
export 'ports/auth_service_port.dart';
export 'ports/data_store_port.dart';
export 'ports/storage_service_port.dart';
export 'ports/analytics_service_port.dart';
export 'ports/realtime_service_port.dart';

// Firebase adapters
export 'adapters/firebase/firebase_auth_adapter.dart';
export 'adapters/firebase/firebase_data_store_adapter.dart';
export 'adapters/firebase/firebase_storage_adapter.dart';
export 'adapters/firebase/firebase_analytics_adapter.dart';

// Common models
export 'models/backend_user.dart';
export 'models/backend_result.dart';
export 'models/query_options.dart';

// Backend factory
export 'backend_factory.dart';
