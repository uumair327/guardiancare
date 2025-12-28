// Conditional exports for web compatibility
// SQLite is not available on web, so we use stub implementations
export 'daos/daos.dart';
export 'database_service_stub.dart'
    if (dart.library.io) 'database_service.dart';
export 'hive_service.dart';
export 'hive_storage_service.dart';
export 'preferences_storage_service.dart';
export 'sqlite_storage_service.dart';
export 'storage_manager.dart';
