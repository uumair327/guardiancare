import 'dart:async';
import 'package:guardiancare/core/util/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/backend_result.dart';
import '../../ports/realtime_service_port.dart';
import 'supabase_initializer.dart';

/// Supabase implementation of [IRealtimeService].
///
/// This adapter implements real-time subscriptions using Supabase Realtime.
///
/// ## Key Differences from Firebase Realtime
///
/// | Firebase | Supabase |
/// |----------|----------|
/// | onSnapshot | postgres_changes |
/// | DocumentReference listeners | Row-level subscriptions |
/// | Query listeners | Filter-based channels |
/// | Auto-reconnection | Manual reconnection |
///
/// ## Setup Required
///
/// 1. Enable Realtime in Supabase Dashboard for each table
/// 2. Configure publication settings
///
/// ## Realtime Events
/// - INSERT: New row added
/// - UPDATE: Row modified
/// - DELETE: Row removed
/// - * : All changes
class SupabaseRealtimeAdapter implements IRealtimeService {
  SupabaseRealtimeAdapter() : _client = SupabaseInitializer.client {
    Log.d('SupabaseRealtimeAdapter: Initialized');
  }

  final SupabaseClient _client;
  final Map<String, RealtimeChannel> _channels = {};
  final Map<String, StreamController<Map<String, dynamic>>> _controllers = {};

  RealtimeConnectionState _connectionState = RealtimeConnectionState.connected;
  final _connectionStateController =
      StreamController<RealtimeConnectionState>.broadcast();
  // ignore: close_sinks
  final _syncStateController = StreamController<SyncState>.broadcast();

  // ============================================================================
  // Connection Management
  // ============================================================================

  @override
  Future<BackendResult<void>> connect() async {
    // Supabase manages connections automatically
    _connectionState = RealtimeConnectionState.connected;
    _connectionStateController.add(_connectionState);
    return const BackendResult.success(null);
  }

  @override
  Future<BackendResult<void>> disconnect() async {
    // Cancel all subscriptions
    for (final channel in _channels.values) {
      await _client.removeChannel(channel);
    }
    _channels.clear();

    // Close all controllers
    for (final controller in _controllers.values) {
      await controller.close();
    }
    _controllers.clear();

    _connectionState = RealtimeConnectionState.disconnected;
    _connectionStateController.add(_connectionState);

    return const BackendResult.success(null);
  }

  @override
  bool get isConnected => _connectionState == RealtimeConnectionState.connected;

  @override
  Stream<RealtimeConnectionState> get connectionState =>
      _connectionStateController.stream;

  // ============================================================================
  // Subscriptions
  // ============================================================================

  @override
  Stream<Map<String, dynamic>> subscribe(String channel) {
    // Parse channel path (e.g., 'forum' or 'forum/postId')
    final segments = channel.split('/');

    if (_controllers.containsKey(channel)) {
      return _controllers[channel]!.stream;
    }

    final controller = StreamController<Map<String, dynamic>>.broadcast(
      onCancel: () => _cleanupChannel(channel),
    );
    _controllers[channel] = controller;

    final tableName = segments[0];

    // Create Supabase realtime channel
    final realtimeChannel = _client.channel('public:$channel');

    if (segments.length == 1) {
      // Collection subscription (all rows in table)
      realtimeChannel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: tableName,
        callback: (payload) {
          _handlePayload(payload, channel, controller);
        },
      );
    } else if (segments.length == 2) {
      // Document subscription (specific row by ID)
      final documentId = segments[1];
      realtimeChannel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: tableName,
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id',
          value: documentId,
        ),
        callback: (payload) {
          _handlePayload(payload, channel, controller);
        },
      );
    } else if (segments.length >= 3) {
      // Subcollection subscription (e.g., 'forum/postId/comments')
      // Convention: subcollection table = parent_subcollection
      final parentId = segments[1];
      final subcollection = segments[2];
      final subTableName = '${tableName}_$subcollection';
      final parentFk = '${_singularize(tableName)}_id';

      realtimeChannel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: subTableName,
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: parentFk,
          value: parentId,
        ),
        callback: (payload) {
          _handlePayload(payload, channel, controller);
        },
      );
    }

    realtimeChannel.subscribe();
    _channels[channel] = realtimeChannel;

    // Fetch initial data
    _fetchInitialData(channel, segments, controller);

    return controller.stream;
  }

  void _handlePayload(
    PostgresChangePayload payload,
    String channel,
    StreamController<Map<String, dynamic>> controller,
  ) {
    final eventType = switch (payload.eventType) {
      PostgresChangeEvent.insert => 'added',
      PostgresChangeEvent.update => 'modified',
      PostgresChangeEvent.delete => 'removed',
      _ => 'modified',
    };

    final data = {
      'type': eventType,
      'path': channel,
      'newData': payload.newRecord,
      'oldData': payload.oldRecord,
    };

    if (!controller.isClosed) {
      controller.add(data);
    }
  }

  Future<void> _fetchInitialData(
    String channel,
    List<String> segments,
    StreamController<Map<String, dynamic>> controller,
  ) async {
    try {
      final tableName = segments[0];
      List<Map<String, dynamic>> docs;

      if (segments.length == 1) {
        // Collection
        final response = await _client.from(tableName).select();
        docs = List<Map<String, dynamic>>.from(response);
      } else if (segments.length == 2) {
        // Single document
        final documentId = segments[1];
        final response = await _client
            .from(tableName)
            .select()
            .eq('id', documentId)
            .maybeSingle();
        docs = response != null ? [response] : [];
      } else {
        // Subcollection
        final parentId = segments[1];
        final subcollection = segments[2];
        final subTableName = '${tableName}_$subcollection';
        final parentFk = '${_singularize(tableName)}_id';

        final response =
            await _client.from(subTableName).select().eq(parentFk, parentId);
        docs = List<Map<String, dynamic>>.from(response);
      }

      if (!controller.isClosed) {
        controller.add({
          'type': 'collection',
          'path': channel,
          'documents': docs,
        });
      }
    } on Object catch (e) {
      Log.w('SupabaseRealtime: Error fetching initial data: $e');
    }
  }

  @override
  Stream<Map<String, dynamic>> subscribeMultiple(List<String> channels) {
    // ignore: close_sinks
    final controller = StreamController<Map<String, dynamic>>.broadcast();
    final subscriptions = <StreamSubscription>[];

    for (final channel in channels) {
      final sub = subscribe(channel).listen(
        controller.add,
        onError: (e) => controller.addError(e),
      );
      subscriptions.add(sub);
    }

    controller.onCancel = () async {
      for (final sub in subscriptions) {
        await sub.cancel();
      }
      await controller.close();
    };

    return controller.stream;
  }

  @override
  Future<BackendResult<void>> unsubscribe(String channel) async {
    await _cleanupChannel(channel);
    return const BackendResult.success(null);
  }

  @override
  Future<BackendResult<void>> unsubscribeAll() async {
    final channelKeys = List<String>.from(_channels.keys);
    for (final channel in channelKeys) {
      await _cleanupChannel(channel);
    }
    return const BackendResult.success(null);
  }

  Future<void> _cleanupChannel(String channel) async {
    final realtimeChannel = _channels.remove(channel);
    final controller = _controllers.remove(channel);

    if (realtimeChannel != null) {
      await _client.removeChannel(realtimeChannel);
    }

    if (controller != null && !controller.isClosed) {
      await controller.close();
    }
  }

  @override
  List<String> get activeSubscriptions => _channels.keys.toList();

  // ============================================================================
  // Presence
  // ============================================================================

  @override
  Future<BackendResult<void>> setPresence(Map<String, dynamic> data) async {
    try {
      // Use a presence channel for user status
      const presenceChannel = 'presence:user';

      var channel = _channels[presenceChannel];
      if (channel == null) {
        channel = _client.channel(presenceChannel);
        _channels[presenceChannel] = channel;
        channel.subscribe();
      }

      await channel.track({
        ...data,
        'last_seen': DateTime.now().toIso8601String(),
      });

      return const BackendResult.success(null);
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<Map<String, dynamic>?>> getPresence(
    String userId,
  ) async {
    try {
      // Presence data is typically stored in a 'presence' table
      final response = await _client
          .from('presence')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return BackendResult.success(response);
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Stream<Map<String, dynamic>?> streamPresence(String userId) {
    return _client
        .from('presence')
        .stream(primaryKey: ['user_id'])
        .eq('user_id', userId)
        .map((data) => data.isNotEmpty ? data.first : null);
  }

  @override
  Stream<List<String>> streamOnlineUsers(String channel) {
    // Use Supabase Presence for online users
    final presenceChannel = _client.channel('presence:$channel');
    // ignore: close_sinks
    final controller = StreamController<List<String>>.broadcast();

    presenceChannel.onPresenceSync((payload) {
      final state = presenceChannel.presenceState();
      // Extract user IDs from presence state
      // Each item in the list contains presences array with user data
      final userIds = <String>[];
      for (final presenceState in state) {
        for (final presence in presenceState.presences) {
          final userId = presence.payload['user_id'] as String?;
          if (userId != null && !userIds.contains(userId)) {
            userIds.add(userId);
          }
        }
      }
      controller.add(userIds);
    }).subscribe();

    controller.onCancel = () async {
      await _client.removeChannel(presenceChannel);
      await controller.close();
    };

    return controller.stream;
  }

  // ============================================================================
  // Sync
  // ============================================================================

  @override
  Future<BackendResult<void>> enableOfflinePersistence() async {
    // Supabase doesn't have built-in offline persistence like Firestore
    // This would need to be implemented with a local database
    return const BackendResult.success(null);
  }

  @override
  Future<BackendResult<void>> disableOfflinePersistence() async {
    return const BackendResult.success(null);
  }

  @override
  Future<BackendResult<void>> sync() async {
    // No-op for Supabase - it's always in sync when connected
    return const BackendResult.success(null);
  }

  @override
  bool get isSynced => isConnected;

  @override
  Stream<SyncState> get syncState => _syncStateController.stream;

  // ============================================================================
  // Helpers
  // ============================================================================

  String _singularize(String plural) {
    if (plural.endsWith('ies')) {
      return '${plural.substring(0, plural.length - 3)}y';
    } else if (plural.endsWith('s')) {
      return plural.substring(0, plural.length - 1);
    }
    return plural;
  }
}
