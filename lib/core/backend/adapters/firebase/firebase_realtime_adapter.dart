import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/backend_result.dart';
import '../../ports/realtime_service_port.dart';

/// Firebase implementation of [IRealtimeService].
///
/// This adapter implements real-time features using Firestore's snapshot
/// listeners. For more complex real-time requirements (presence, sync status),
/// Firebase Realtime Database can be integrated.
///
/// ## Features
/// - Document and collection subscriptions via Firestore listeners
/// - Offline persistence (handled by Firestore SDK)
/// - Automatic reconnection
///
/// ## Usage
/// ```dart
/// final realtime = FirebaseRealtimeAdapter();
///
/// // Subscribe to forum posts
/// realtime.subscribe('forum').listen((data) {
///   print('Forum updated: $data');
/// });
/// ```
class FirebaseRealtimeAdapter implements IRealtimeService {
  FirebaseRealtimeAdapter() : _firestore = FirebaseFirestore.instance {
    debugPrint('FirebaseRealtimeAdapter: Created');
  }

  final FirebaseFirestore _firestore;
  final Map<String, StreamSubscription> _subscriptions = {};
  final Map<String, StreamController<Map<String, dynamic>>> _controllers = {};

  RealtimeConnectionState _connectionState = RealtimeConnectionState.connected;
  final _connectionStateController =
      StreamController<RealtimeConnectionState>.broadcast();

  // ============================================================================
  // Connection Management
  // ============================================================================

  @override
  Future<BackendResult<void>> connect() async {
    // Firestore manages connections automatically
    _connectionState = RealtimeConnectionState.connected;
    _connectionStateController.add(_connectionState);
    return const BackendResult.success(null);
  }

  @override
  Future<BackendResult<void>> disconnect() async {
    // Cancel all subscriptions
    for (final sub in _subscriptions.values) {
      await sub.cancel();
    }
    _subscriptions.clear();

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
    // Parse channel path (e.g., 'forum' or 'forum/postId/comments')
    final segments = channel.split('/');

    if (_controllers.containsKey(channel)) {
      return _controllers[channel]!.stream;
    }

    final controller = StreamController<Map<String, dynamic>>.broadcast(
      onCancel: () => _cleanupChannel(channel),
    );
    _controllers[channel] = controller;

    if (segments.length == 1) {
      // Collection subscription
      final subscription =
          _firestore.collection(segments[0]).snapshots().listen(
        (snapshot) {
          final data = {
            'type': 'collection',
            'path': channel,
            'documents': snapshot.docs
                .map((doc) => {
                      'id': doc.id,
                      ...doc.data(),
                    })
                .toList(),
            'changes': snapshot.docChanges
                .map((change) => {
                      'type': change.type.name,
                      'id': change.doc.id,
                      'data': change.doc.data(),
                    })
                .toList(),
          };
          controller.add(data);
        },
        onError: (error) {
          controller.addError(error);
        },
      );
      _subscriptions[channel] = subscription;
    } else if (segments.length == 2) {
      // Document subscription
      final subscription = _firestore
          .collection(segments[0])
          .doc(segments[1])
          .snapshots()
          .listen(
        (snapshot) {
          final data = {
            'type': 'document',
            'path': channel,
            'exists': snapshot.exists,
            'id': snapshot.id,
            'data': snapshot.data(),
          };
          controller.add(data);
        },
        onError: (error) {
          controller.addError(error);
        },
      );
      _subscriptions[channel] = subscription;
    } else if (segments.length >= 3) {
      // Subcollection subscription
      final collectionPath = segments.take(segments.length - 1).join('/');
      final subscription =
          _firestore.collection(collectionPath).snapshots().listen(
        (snapshot) {
          final data = {
            'type': 'subcollection',
            'path': channel,
            'documents': snapshot.docs
                .map((doc) => {
                      'id': doc.id,
                      ...doc.data(),
                    })
                .toList(),
          };
          controller.add(data);
        },
        onError: (error) {
          controller.addError(error);
        },
      );
      _subscriptions[channel] = subscription;
    }

    return controller.stream;
  }

  @override
  Stream<Map<String, dynamic>> subscribeMultiple(List<String> channels) {
    final controller = StreamController<Map<String, dynamic>>.broadcast();

    for (final channel in channels) {
      subscribe(channel).listen(
        (data) => controller.add({...data, 'channel': channel}),
        onError: (error) => controller.addError(error),
      );
    }

    return controller.stream;
  }

  @override
  Future<BackendResult<void>> unsubscribe(String channel) async {
    await _cleanupChannel(channel);
    return const BackendResult.success(null);
  }

  @override
  Future<BackendResult<void>> unsubscribeAll() async {
    final channels = List<String>.from(_subscriptions.keys);
    for (final channel in channels) {
      await _cleanupChannel(channel);
    }
    return const BackendResult.success(null);
  }

  @override
  List<String> get activeSubscriptions => _subscriptions.keys.toList();

  Future<void> _cleanupChannel(String channel) async {
    await _subscriptions[channel]?.cancel();
    _subscriptions.remove(channel);
    await _controllers[channel]?.close();
    _controllers.remove(channel);
  }

  // ============================================================================
  // Presence
  // ============================================================================

  @override
  Future<BackendResult<void>> setPresence(Map<String, dynamic> data) async {
    // Firestore doesn't have built-in presence like Realtime Database
    // Implement using a 'presence' collection with timestamps
    try {
      final userId = data['userId'] as String?;
      if (userId == null) {
        return const BackendResult.failure(
          BackendError(
            message: 'userId is required for presence',
            code: BackendErrorCode.invalidData,
          ),
        );
      }

      await _firestore.collection('presence').doc(userId).set({
        ...data,
        'lastSeen': FieldValue.serverTimestamp(),
        'online': true,
      }, SetOptions(merge: true));

      return const BackendResult.success(null);
    } catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<Map<String, dynamic>?>> getPresence(
      String userId) async {
    try {
      final doc = await _firestore.collection('presence').doc(userId).get();
      return BackendResult.success(doc.data());
    } catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Stream<Map<String, dynamic>?> streamPresence(String userId) {
    return _firestore
        .collection('presence')
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  @override
  Stream<List<String>> streamOnlineUsers(String channel) {
    // Query users who are online and were seen recently (e.g., last 5 minutes)
    final threshold = DateTime.now().subtract(const Duration(minutes: 5));

    return _firestore
        .collection('presence')
        .where('online', isEqualTo: true)
        .where('lastSeen', isGreaterThan: Timestamp.fromDate(threshold))
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  // ============================================================================
  // Sync
  // ============================================================================

  @override
  Future<BackendResult<void>> enableOfflinePersistence() async {
    // Firestore handles this automatically with settings
    // This is typically set during Firestore initialization
    try {
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      return const BackendResult.success(null);
    } catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<void>> disableOfflinePersistence() async {
    // Cannot disable after initialization in Firestore
    return const BackendResult.failure(
      BackendError(
        message: 'Cannot disable persistence after Firestore initialization',
        code: BackendErrorCode.operationNotAllowed,
      ),
    );
  }

  @override
  Future<BackendResult<void>> sync() async {
    // Firestore syncs automatically
    // Force sync by waiting for pending writes
    try {
      await _firestore.waitForPendingWrites();
      return const BackendResult.success(null);
    } catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  bool get isSynced => true; // Firestore manages this internally

  @override
  Stream<SyncState> get syncState {
    // Firestore doesn't expose sync state directly
    // Return a stream that indicates synced state
    return Stream.value(const SyncState(
      isSynced: true,
      pendingWrites: 0,
    ));
  }
}
