// Conditional exports for web compatibility
// SQLite is not available on web, so we use stub implementations
export 'cache_dao_stub.dart'
    if (dart.library.io) 'cache_dao.dart';
export 'quiz_dao_stub.dart'
    if (dart.library.io) 'quiz_dao.dart';
export 'video_dao_stub.dart'
    if (dart.library.io) 'video_dao.dart';
