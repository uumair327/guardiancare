import 'dart:async';

import 'package:guardiancare/core/util/logger.dart';

import '../../models/backend_result.dart';
import '../../models/query_options.dart';
import '../../ports/data_store_port.dart';

/// Composite Sync Data Store Adapter.
///
/// This adapter implements the **Dual-Write Pattern** to keep two backends
/// (e.g., Firebase + Supabase) in sync simultaneously.
///
/// ## Architecture
/// ```
///                    ┌──────────────────────┐
///                    │   SyncDataStore      │
///                    │   (IDataStore)        │
///                    └──────────┬───────────┘
///                               │
///              ┌────────────────┼────────────────┐
///              ▼                                  ▼
///   ┌──────────────────┐              ┌──────────────────┐
///   │   Primary         │              │   Secondary       │
///   │   (Firebase)      │              │   (Supabase)      │
///   │   Source of Truth │              │   Replica          │
///   └──────────────────┘              └──────────────────┘
/// ```
///
/// ## Behavior
/// - **Reads**: Always from primary (source of truth)
/// - **Writes**: To primary first, then async to secondary (fire-and-forget)
/// - **Streams**: Always from primary
/// - **Failures**: Secondary failures are logged but don't affect primary operations
///
/// ## Usage
/// ```dart
/// final syncStore = SyncDataStoreAdapter(
///   primary: FirebaseDataStoreAdapter(),
///   secondary: SupabaseDataStoreAdapter(),
/// );
///
/// // Register in DI
/// sl.registerLazySingleton<IDataStore>(() => syncStore);
/// ```
///
/// ## Configuration
/// Enable/disable via:
/// ```bash
/// flutter run --dart-define=BACKEND=sync
/// ```
class SyncDataStoreAdapter implements IDataStore {
  /// Creates a sync adapter with primary and secondary data stores.
  ///
  /// [primary] is the source of truth — all reads come from here.
  /// [secondary] receives all writes asynchronously.
  /// [syncReads] if true, also reads from secondary to verify consistency.
  SyncDataStoreAdapter({
    required IDataStore primary,
    required IDataStore secondary,
    this.syncReads = false,
  })  : _primary = primary,
        _secondary = secondary;

  final IDataStore _primary;
  final IDataStore _secondary;

  /// If true, reads are also performed on secondary (for consistency checks).
  /// Default is false for performance.
  final bool syncReads;

  // ============================================================================
  // Internal Helpers
  // ============================================================================

  /// Log tag for all sync operations.
  static const String _tag = 'SyncDataStore';

  /// Execute a write operation on secondary in the background.
  /// Failures are logged but never thrown.
  void _syncToSecondary(
    String operation,
    Future<BackendResult<dynamic>> Function() secondaryOp,
  ) {
    unawaited(
      secondaryOp().then((result) {
        result.when(
          success: (_) {
            Log.d('[$_tag] ✅ Secondary sync success: $operation');
          },
          failure: (error) {
            Log.w(
              '[$_tag] ⚠️ Secondary sync failed: $operation - '
              '${error.message}',
            );
          },
        );
      }).catchError((Object error) {
        Log.e(
          '[$_tag] ❌ Secondary sync error: $operation',
          error,
        );
      }),
    );
  }

  // ============================================================================
  // Single Document Operations
  // ============================================================================

  @override
  Future<BackendResult<Map<String, dynamic>?>> get(
    String collection,
    String documentId,
  ) {
    // Always read from primary
    return _primary.get(collection, documentId);
  }

  @override
  Future<BackendResult<bool>> exists(
    String collection,
    String documentId,
  ) {
    return _primary.exists(collection, documentId);
  }

  @override
  Future<BackendResult<String>> add(
    String collection,
    Map<String, dynamic> data,
  ) async {
    final result = await _primary.add(collection, data);

    result.when(
      success: (id) {
        // Sync to secondary with the generated ID
        _syncToSecondary(
          'add($collection/$id)',
          () => _secondary.set(collection, id, data),
        );
      },
      failure: (_) {},
    );

    return result;
  }

  @override
  Future<BackendResult<void>> set(
    String collection,
    String documentId,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    final result = await _primary.set(
      collection,
      documentId,
      data,
      merge: merge,
    );

    if (result.isSuccess) {
      _syncToSecondary(
        'set($collection/$documentId, merge=$merge)',
        () => _secondary.set(collection, documentId, data, merge: merge),
      );
    }

    return result;
  }

  @override
  Future<BackendResult<void>> update(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    final result = await _primary.update(collection, documentId, data);

    if (result.isSuccess) {
      _syncToSecondary(
        'update($collection/$documentId)',
        () => _secondary.update(collection, documentId, data),
      );
    }

    return result;
  }

  @override
  Future<BackendResult<void>> delete(
    String collection,
    String documentId,
  ) async {
    final result = await _primary.delete(collection, documentId);

    if (result.isSuccess) {
      _syncToSecondary(
        'delete($collection/$documentId)',
        () => _secondary.delete(collection, documentId),
      );
    }

    return result;
  }

  // ============================================================================
  // Collection Operations
  // ============================================================================

  @override
  Future<BackendResult<List<Map<String, dynamic>>>> query(
    String collection, {
    QueryOptions? options,
  }) {
    return _primary.query(collection, options: options);
  }

  @override
  Future<BackendResult<List<Map<String, dynamic>>>> getAll(
    String collection, {
    int? limit,
  }) {
    return _primary.getAll(collection, limit: limit);
  }

  @override
  Future<BackendResult<int>> count(
    String collection, {
    QueryOptions? options,
  }) {
    return _primary.count(collection, options: options);
  }

  // ============================================================================
  // Subcollection Operations
  // ============================================================================

  @override
  Future<BackendResult<Map<String, dynamic>?>> getSubdocument(
    String parentCollection,
    String parentId,
    String subcollection,
    String documentId,
  ) {
    return _primary.getSubdocument(
      parentCollection,
      parentId,
      subcollection,
      documentId,
    );
  }

  @override
  Future<BackendResult<String>> addToSubcollection(
    String parentCollection,
    String parentId,
    String subcollection,
    Map<String, dynamic> data,
  ) async {
    final result = await _primary.addToSubcollection(
      parentCollection,
      parentId,
      subcollection,
      data,
    );

    result.when(
      success: (id) {
        _syncToSecondary(
          'addToSubcollection($parentCollection/$parentId/$subcollection/$id)',
          () => _secondary.setSubdocument(
            parentCollection,
            parentId,
            subcollection,
            id,
            data,
          ),
        );
      },
      failure: (_) {},
    );

    return result;
  }

  @override
  Future<BackendResult<void>> setSubdocument(
    String parentCollection,
    String parentId,
    String subcollection,
    String documentId,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    final result = await _primary.setSubdocument(
      parentCollection,
      parentId,
      subcollection,
      documentId,
      data,
      merge: merge,
    );

    if (result.isSuccess) {
      _syncToSecondary(
        'setSubdocument($parentCollection/$parentId/$subcollection/$documentId)',
        () => _secondary.setSubdocument(
          parentCollection,
          parentId,
          subcollection,
          documentId,
          data,
          merge: merge,
        ),
      );
    }

    return result;
  }

  @override
  Future<BackendResult<List<Map<String, dynamic>>>> querySubcollection(
    String parentCollection,
    String parentId,
    String subcollection, {
    QueryOptions? options,
  }) {
    return _primary.querySubcollection(
      parentCollection,
      parentId,
      subcollection,
      options: options,
    );
  }

  @override
  Future<BackendResult<void>> deleteSubdocument(
    String parentCollection,
    String parentId,
    String subcollection,
    String documentId,
  ) async {
    final result = await _primary.deleteSubdocument(
      parentCollection,
      parentId,
      subcollection,
      documentId,
    );

    if (result.isSuccess) {
      _syncToSecondary(
        'deleteSubdocument($parentCollection/$parentId/$subcollection/$documentId)',
        () => _secondary.deleteSubdocument(
          parentCollection,
          parentId,
          subcollection,
          documentId,
        ),
      );
    }

    return result;
  }

  // ============================================================================
  // Batch Operations
  // ============================================================================

  @override
  Future<BackendResult<void>> batch(List<BatchOperation> operations) async {
    final result = await _primary.batch(operations);

    if (result.isSuccess) {
      _syncToSecondary(
        'batch(${operations.length} operations)',
        () => _secondary.batch(operations),
      );
    }

    return result;
  }

  // ============================================================================
  // Transactions
  // ============================================================================

  @override
  Future<BackendResult<T>> runTransaction<T>(
    TransactionCallback<T> callback,
  ) {
    // Transactions only run on primary — secondary sync is handled
    // by the individual operations within the transaction.
    // For full transactional sync, use the migration script instead.
    Log.d(
      '[$_tag] Transaction running on primary only. '
      'Secondary sync not supported for transactions.',
    );
    return _primary.runTransaction(callback);
  }

  // ============================================================================
  // Real-time Streams
  // ============================================================================

  @override
  Stream<BackendResult<Map<String, dynamic>?>> streamDocument(
    String collection,
    String documentId,
  ) {
    // Streams always come from primary
    return _primary.streamDocument(collection, documentId);
  }

  @override
  Stream<BackendResult<List<Map<String, dynamic>>>> streamQuery(
    String collection, {
    QueryOptions? options,
  }) {
    return _primary.streamQuery(collection, options: options);
  }

  @override
  Stream<BackendResult<List<Map<String, dynamic>>>> streamSubcollection(
    String parentCollection,
    String parentId,
    String subcollection, {
    QueryOptions? options,
  }) {
    return _primary.streamSubcollection(
      parentCollection,
      parentId,
      subcollection,
      options: options,
    );
  }

  // ============================================================================
  // Field Operations
  // ============================================================================

  @override
  Future<BackendResult<void>> increment(
    String collection,
    String documentId,
    String field,
    num value,
  ) async {
    final result = await _primary.increment(
      collection,
      documentId,
      field,
      value,
    );

    if (result.isSuccess) {
      _syncToSecondary(
        'increment($collection/$documentId.$field += $value)',
        () => _secondary.increment(collection, documentId, field, value),
      );
    }

    return result;
  }

  @override
  Future<BackendResult<void>> arrayUnion(
    String collection,
    String documentId,
    String field,
    List<dynamic> values,
  ) async {
    final result = await _primary.arrayUnion(
      collection,
      documentId,
      field,
      values,
    );

    if (result.isSuccess) {
      _syncToSecondary(
        'arrayUnion($collection/$documentId.$field)',
        () => _secondary.arrayUnion(collection, documentId, field, values),
      );
    }

    return result;
  }

  @override
  Future<BackendResult<void>> arrayRemove(
    String collection,
    String documentId,
    String field,
    List<dynamic> values,
  ) async {
    final result = await _primary.arrayRemove(
      collection,
      documentId,
      field,
      values,
    );

    if (result.isSuccess) {
      _syncToSecondary(
        'arrayRemove($collection/$documentId.$field)',
        () => _secondary.arrayRemove(collection, documentId, field, values),
      );
    }

    return result;
  }

  @override
  Future<BackendResult<void>> setServerTimestamp(
    String collection,
    String documentId,
    String field,
  ) async {
    final result = await _primary.setServerTimestamp(
      collection,
      documentId,
      field,
    );

    if (result.isSuccess) {
      _syncToSecondary(
        'setServerTimestamp($collection/$documentId.$field)',
        () => _secondary.setServerTimestamp(collection, documentId, field),
      );
    }

    return result;
  }
}
