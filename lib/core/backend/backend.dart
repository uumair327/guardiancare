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
library;

export 'adapters/firebase/firebase_analytics_adapter.dart';
// Firebase adapters
export 'adapters/firebase/firebase_auth_adapter.dart';
export 'adapters/firebase/firebase_data_store_adapter.dart';
export 'adapters/firebase/firebase_realtime_adapter.dart';
export 'adapters/firebase/firebase_storage_adapter.dart';
// Supabase adapters (skeleton implementations - not yet functional)
// Uncomment when supabase_flutter is added to pubspec.yaml
// export 'adapters/supabase/supabase_auth_adapter.dart';
// export 'adapters/supabase/supabase_data_store_adapter.dart';
// export 'adapters/supabase/supabase_storage_adapter.dart';
// export 'adapters/supabase/supabase_realtime_adapter.dart';

// Supabase initializer (can be exported even without full implementation)
export 'adapters/supabase/supabase_initializer.dart';
// Sync adapter (dual-write to both backends)
export 'adapters/sync/sync_data_store_adapter.dart';
// Backend factory
export 'backend_factory.dart';
// Configuration (Feature Flags & Secrets)
export 'config/backend_config.dart';
export 'config/backend_secrets.dart';
export 'models/backend_result.dart';
// Common models
export 'models/backend_user.dart';
export 'models/query_options.dart';
export 'ports/analytics_service_port.dart';
// Core abstractions (Ports)
export 'ports/auth_service_port.dart';
export 'ports/data_store_port.dart';
export 'ports/realtime_service_port.dart';
export 'ports/storage_service_port.dart';
