/// Supabase backend adapters.
///
/// This barrel file exports all Supabase-specific implementations
/// of the backend ports.
///
/// ## Usage
///
/// To use Supabase as your backend:
///
/// 1. Run with flag: `flutter run --dart-define=BACKEND=supabase`
/// 2. Set environment variables:
///    - `SUPABASE_URL`: Your Supabase project URL
///    - `SUPABASE_ANON_KEY`: Your Supabase anon/public key
///
/// ## Architecture
///
/// These adapters implement the ports defined in `../ports/`:
/// - [SupabaseAuthAdapter] → [IAuthService]
/// - [SupabaseDataStoreAdapter] → [IDataStore]
/// - [SupabaseStorageAdapter] → [IStorageService]
/// - [SupabaseRealtimeAdapter] → [IRealtimeService]
///
/// The [BackendFactory] automatically selects these adapters when
/// the BACKEND=supabase flag is set.
library;

// Initialization
export 'supabase_initializer.dart';

// Adapters
export 'supabase_auth_adapter.dart';
export 'supabase_data_store_adapter.dart';
export 'supabase_storage_adapter.dart';
export 'supabase_realtime_adapter.dart';
