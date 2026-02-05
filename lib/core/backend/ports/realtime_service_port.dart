import '../models/backend_result.dart';

/// Real-time service port (interface).
///
/// This is the PORT in Hexagonal Architecture - it defines what the application
/// needs from real-time features WITHOUT specifying how it's implemented.
///
/// ## Implementations
/// - `FirebaseRealtimeAdapter` - Firebase Realtime Database / Firestore listeners
/// - `SupabaseRealtimeAdapter` - Supabase Realtime (future)
/// - `WebSocketRealtimeAdapter` - Custom WebSocket (future)
/// - `MockRealtimeAdapter` - For testing
///
/// ## Usage
/// ```dart
/// class ChatService {
///   final IRealtimeService realtime;
///
///   ChatService(this.realtime);
///
///   Stream<List<Message>> getMessages(String chatId) {
///     return realtime.subscribe(
///       channel: 'chats/$chatId/messages',
///     ).map((data) => data.map(Message.fromJson).toList());
///   }
/// }
/// ```
abstract interface class IRealtimeService {
  // ==================== Connection Management ====================
  /// Connect to the real-time service
  Future<BackendResult<void>> connect();

  /// Disconnect from the real-time service
  Future<BackendResult<void>> disconnect();

  /// Check if connected
  bool get isConnected;

  /// Stream of connection state changes
  Stream<RealtimeConnectionState> get connectionState;

  // ==================== Subscriptions ====================
  /// Subscribe to a channel/path
  Stream<Map<String, dynamic>> subscribe(String channel);

  /// Subscribe to multiple channels
  Stream<Map<String, dynamic>> subscribeMultiple(List<String> channels);

  /// Unsubscribe from a channel
  Future<BackendResult<void>> unsubscribe(String channel);

  /// Unsubscribe from all channels
  Future<BackendResult<void>> unsubscribeAll();

  /// Get list of active subscriptions
  List<String> get activeSubscriptions;

  // ==================== Presence ====================
  /// Set user presence data
  Future<BackendResult<void>> setPresence(Map<String, dynamic> data);

  /// Get presence for a user
  Future<BackendResult<Map<String, dynamic>?>> getPresence(String userId);

  /// Stream presence changes for a user
  Stream<Map<String, dynamic>?> streamPresence(String userId);

  /// Stream online users in a channel
  Stream<List<String>> streamOnlineUsers(String channel);

  // ==================== Sync ====================
  /// Enable offline persistence
  Future<BackendResult<void>> enableOfflinePersistence();

  /// Disable offline persistence
  Future<BackendResult<void>> disableOfflinePersistence();

  /// Force sync with server
  Future<BackendResult<void>> sync();

  /// Check if data is synced
  bool get isSynced;

  /// Stream of sync state changes
  Stream<SyncState> get syncState;
}

/// Connection state
enum RealtimeConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

/// Sync state
class SyncState {
  const SyncState({
    required this.isSynced,
    required this.pendingWrites,
    this.lastSyncTime,
  });

  final bool isSynced;
  final int pendingWrites;
  final DateTime? lastSyncTime;
}
