import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/backend_result.dart';
import '../../models/query_options.dart';
import '../../ports/data_store_port.dart';
import 'supabase_initializer.dart';

/// Supabase implementation of [IDataStore].
///
/// This adapter implements data operations using Supabase PostgreSQL.
///
/// ## Key Differences from Firestore
///
/// | Firestore | Supabase |
/// |-----------|----------|
/// | Collections | Tables |
/// | Documents | Rows |
/// | Subcollections | Foreign keys + joins |
/// | Auto-generated IDs | UUID primary keys |
/// | Nested data | JSON columns or related tables |
///
/// ## Setup Required
///
/// 1. Create tables in Supabase that match your Firestore collections
/// 2. Enable Row Level Security (RLS) for each table
/// 3. Set up appropriate policies for read/write access
///
/// ## Table Naming Convention
/// This adapter uses snake_case for table names (PostgreSQL convention)
/// e.g., 'users', 'forum_posts', 'quiz_questions'
class SupabaseDataStoreAdapter implements IDataStore {
  SupabaseDataStoreAdapter() : _client = SupabaseInitializer.client {
    debugPrint('SupabaseDataStoreAdapter: Initialized with Supabase');
  }

  final SupabaseClient _client;
  SupabaseQueryBuilder _table(String collection) => _client.from(collection);

  // ============================================================================
  // Single Document Operations
  // ============================================================================

  @override
  Future<BackendResult<Map<String, dynamic>?>> get(
    String collection,
    String documentId,
  ) async {
    try {
      final response =
          await _table(collection).select().eq('id', documentId).maybeSingle();
      return BackendResult.success(response);
    } on PostgrestException catch (e) {
      return BackendResult.failure(_mapPostgrestError(e));
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<bool>> exists(
    String collection,
    String documentId,
  ) async {
    try {
      final response = await _table(collection)
          .select('id')
          .eq('id', documentId)
          .maybeSingle();
      return BackendResult.success(response != null);
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<String>> add(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      final dataWithTimestamp = {
        ...data,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      final response = await _table(collection)
          .insert(dataWithTimestamp)
          .select('id')
          .single();
      return BackendResult.success(response['id'] as String);
    } on PostgrestException catch (e) {
      return BackendResult.failure(_mapPostgrestError(e));
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<void>> set(
    String collection,
    String documentId,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    try {
      final dataWithId = {
        ...data,
        'id': documentId,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (merge) {
        // Upsert - insert or update
        await _table(collection).upsert(dataWithId);
      } else {
        // Check if exists
        final exists = await _table(collection)
            .select('id')
            .eq('id', documentId)
            .maybeSingle();
        if (exists != null) {
          await _table(collection).update(dataWithId).eq('id', documentId);
        } else {
          await _table(collection).insert({
            ...dataWithId,
            'createdAt': DateTime.now().toIso8601String(),
          });
        }
      }
      return const BackendResult.success(null);
    } on PostgrestException catch (e) {
      return BackendResult.failure(_mapPostgrestError(e));
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<void>> update(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      final dataWithTimestamp = {
        ...data,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await _table(collection).update(dataWithTimestamp).eq('id', documentId);
      return const BackendResult.success(null);
    } on PostgrestException catch (e) {
      return BackendResult.failure(_mapPostgrestError(e));
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<void>> delete(
    String collection,
    String documentId,
  ) async {
    try {
      await _table(collection).delete().eq('id', documentId);
      return const BackendResult.success(null);
    } on PostgrestException catch (e) {
      return BackendResult.failure(_mapPostgrestError(e));
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  // ============================================================================
  // Collection Operations
  // ============================================================================

  @override
  Future<BackendResult<List<Map<String, dynamic>>>> query(
    String collection, {
    QueryOptions? options,
  }) async {
    try {
      dynamic query = _table(collection).select();

      if (options != null) {
        // Apply filters
        for (final filter in options.filters) {
          query = _applyFilter(query, filter);
        }

        // Apply ordering
        for (final order in options.orderBy) {
          query = query.order(order.field, ascending: !order.descending);
        }

        // Apply limit
        if (options.limit != null) {
          query = query.limit(options.limit!);
        }

        // Apply offset
        if (options.offset != null) {
          query = query.range(
              options.offset!, options.offset! + (options.limit ?? 100) - 1);
        }
      }

      final response = await query;
      return BackendResult.success(List<Map<String, dynamic>>.from(response));
    } on PostgrestException catch (e) {
      return BackendResult.failure(_mapPostgrestError(e));
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<List<Map<String, dynamic>>>> getAll(
    String collection, {
    int? limit,
  }) async {
    try {
      dynamic query = _table(collection).select();
      if (limit != null) {
        query = query.limit(limit);
      }
      final response = await query;
      return BackendResult.success(List<Map<String, dynamic>>.from(response));
    } on PostgrestException catch (e) {
      return BackendResult.failure(_mapPostgrestError(e));
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<int>> count(
    String collection, {
    QueryOptions? options,
  }) async {
    try {
      dynamic query = _table(collection).select('id');
      if (options != null) {
        for (final filter in options.filters) {
          query = _applyFilter(query, filter);
        }
      }
      final response = await query;
      return BackendResult.success((response as List).length);
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  // ============================================================================
  // Subcollection Operations
  // ============================================================================

  // Supabase uses foreign keys instead of nested collections
  // Convention: subcollection table name = parent_subcollection (e.g., posts_comments)

  @override
  Future<BackendResult<Map<String, dynamic>?>> getSubdocument(
    String parentCollection,
    String parentId,
    String subcollection,
    String documentId,
  ) async {
    try {
      final tableName = '${parentCollection}_$subcollection';
      final parentFk = '${_singularize(parentCollection)}Id';
      final response = await _client
          .from(tableName)
          .select()
          .eq(parentFk, parentId)
          .eq('id', documentId)
          .maybeSingle();
      return BackendResult.success(response);
    } on PostgrestException catch (e) {
      return BackendResult.failure(_mapPostgrestError(e));
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<String>> addToSubcollection(
    String parentCollection,
    String parentId,
    String subcollection,
    Map<String, dynamic> data,
  ) async {
    try {
      final tableName = '${parentCollection}_$subcollection';
      final parentFk = '${_singularize(parentCollection)}Id';
      final dataWithFk = {
        ...data,
        parentFk: parentId,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      final response = await _client
          .from(tableName)
          .insert(dataWithFk)
          .select('id')
          .single();
      return BackendResult.success(response['id'] as String);
    } on PostgrestException catch (e) {
      return BackendResult.failure(_mapPostgrestError(e));
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
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
    try {
      final tableName = '${parentCollection}_$subcollection';
      final parentFk = '${_singularize(parentCollection)}Id';
      final dataWithIds = {
        ...data,
        'id': documentId,
        parentFk: parentId,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await _client.from(tableName).upsert(dataWithIds);
      return const BackendResult.success(null);
    } on PostgrestException catch (e) {
      return BackendResult.failure(_mapPostgrestError(e));
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<List<Map<String, dynamic>>>> querySubcollection(
    String parentCollection,
    String parentId,
    String subcollection, {
    QueryOptions? options,
  }) async {
    try {
      final tableName = '${parentCollection}_$subcollection';
      final parentFk = '${_singularize(parentCollection)}Id';
      dynamic query = _client.from(tableName).select().eq(parentFk, parentId);

      if (options != null) {
        for (final filter in options.filters) {
          query = _applyFilter(query, filter);
        }
        for (final order in options.orderBy) {
          query = query.order(order.field, ascending: !order.descending);
        }
        if (options.limit != null) {
          query = query.limit(options.limit!);
        }
      }

      final response = await query;
      return BackendResult.success(List<Map<String, dynamic>>.from(response));
    } on PostgrestException catch (e) {
      return BackendResult.failure(_mapPostgrestError(e));
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<void>> deleteSubdocument(
    String parentCollection,
    String parentId,
    String subcollection,
    String documentId,
  ) async {
    try {
      final tableName = '${parentCollection}_$subcollection';
      await _client.from(tableName).delete().eq('id', documentId);
      return const BackendResult.success(null);
    } on PostgrestException catch (e) {
      return BackendResult.failure(_mapPostgrestError(e));
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  // ============================================================================
  // Batch & Transactions
  // ============================================================================

  @override
  Future<BackendResult<void>> batch(List<BatchOperation> operations) async {
    try {
      // Supabase doesn't have native batch write like Firestore
      // Execute operations sequentially
      for (final op in operations) {
        switch (op.type) {
          case BatchOperationType.set:
            await set(op.collection, op.documentId, op.data!);
          case BatchOperationType.update:
            await update(op.collection, op.documentId, op.data!);
          case BatchOperationType.delete:
            await delete(op.collection, op.documentId);
        }
      }
      return const BackendResult.success(null);
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<T>> runTransaction<T>(
    TransactionCallback<T> callback,
  ) async {
    // Supabase doesn't have client-side transactions like Firestore
    // For atomic operations, use PostgreSQL functions via RPC
    // This is a simplified implementation that just runs the callback
    try {
      final accessor = _SupabaseTransactionContext(this);
      final result = await callback(accessor);
      return BackendResult.success(result);
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(
          message: 'Transaction error: $e',
          code: BackendErrorCode.unknown,
        ),
      );
    }
  }

  // ============================================================================
  // Real-time Streams
  // ============================================================================

  @override
  Stream<BackendResult<Map<String, dynamic>?>> streamDocument(
    String collection,
    String documentId,
  ) {
    return _client
        .from(collection)
        .stream(primaryKey: ['id'])
        .eq('id', documentId)
        .map((data) {
          if (data.isEmpty) return const BackendResult.success(null);
          return BackendResult.success(data.first);
        });
  }

  @override
  Stream<BackendResult<List<Map<String, dynamic>>>> streamQuery(
    String collection, {
    QueryOptions? options,
  }) {
    // Supabase Realtime doesn't support complex queries
    // Use basic streaming and filter on client
    return _client.from(collection).stream(primaryKey: ['id']).map((data) {
      var filtered = List<Map<String, dynamic>>.from(data);
      if (options?.filters != null) {
        for (final filter in options!.filters) {
          filtered = filtered.where((item) {
            final value = item[filter.field];
            return _evaluateFilter(value, filter);
          }).toList();
        }
      }
      if (options?.limit != null) {
        filtered = filtered.take(options!.limit!).toList();
      }
      return BackendResult.success(filtered);
    });
  }

  @override
  Stream<BackendResult<List<Map<String, dynamic>>>> streamSubcollection(
    String parentCollection,
    String parentId,
    String subcollection, {
    QueryOptions? options,
  }) {
    final tableName = '${parentCollection}_$subcollection';
    final parentFk = '${_singularize(parentCollection)}Id';
    return _client.from(tableName).stream(primaryKey: ['id']).map((data) {
      final filtered = data.where((r) => r[parentFk] == parentId).toList();
      return BackendResult.success(filtered);
    });
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
    try {
      // Use RPC for atomic increment
      await _client.rpc('increment_field', params: {
        'table_name': collection,
        'row_id': documentId,
        'field_name': field,
        'increment_by': value,
      });
      return const BackendResult.success(null);
    } on PostgrestException {
      // Fallback to non-atomic update if RPC doesn't exist
      final current = await get(collection, documentId);
      if (current.isSuccess && current.dataOrNull != null) {
        final currentValue = current.dataOrNull![field] as num? ?? 0;
        await update(collection, documentId, {field: currentValue + value});
        return const BackendResult.success(null);
      }
      return const BackendResult.failure(
        BackendError(
          message: 'Document not found',
          code: BackendErrorCode.notFound,
        ),
      );
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<void>> arrayUnion(
    String collection,
    String documentId,
    String field,
    List<dynamic> values,
  ) async {
    try {
      final current = await get(collection, documentId);
      if (current.isSuccess && current.dataOrNull != null) {
        final currentArray =
            List<dynamic>.from(current.dataOrNull![field] as List? ?? []);
        final newArray = {...currentArray, ...values}.toList();
        await update(collection, documentId, {field: newArray});
        return const BackendResult.success(null);
      }
      return const BackendResult.failure(
        BackendError(
          message: 'Document not found',
          code: BackendErrorCode.notFound,
        ),
      );
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<void>> arrayRemove(
    String collection,
    String documentId,
    String field,
    List<dynamic> values,
  ) async {
    try {
      final current = await get(collection, documentId);
      if (current.isSuccess && current.dataOrNull != null) {
        final currentArray =
            List<dynamic>.from(current.dataOrNull![field] as List? ?? []);
        currentArray.removeWhere((e) => values.contains(e));
        await update(collection, documentId, {field: currentArray});
        return const BackendResult.success(null);
      }
      return const BackendResult.failure(
        BackendError(
          message: 'Document not found',
          code: BackendErrorCode.notFound,
        ),
      );
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<void>> setServerTimestamp(
    String collection,
    String documentId,
    String field,
  ) async {
    try {
      await update(collection, documentId, {
        field: DateTime.now().toUtc().toIso8601String(),
      });
      return const BackendResult.success(null);
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  // ============================================================================
  // Helpers
  // ============================================================================

  dynamic _applyFilter(dynamic query, QueryFilter filter) {
    return switch (filter.operator) {
      FilterOperator.equals => query.eq(filter.field, filter.value),
      FilterOperator.notEquals => query.neq(filter.field, filter.value),
      FilterOperator.lessThan => query.lt(filter.field, filter.value),
      FilterOperator.lessThanOrEquals => query.lte(filter.field, filter.value),
      FilterOperator.greaterThan => query.gt(filter.field, filter.value),
      FilterOperator.greaterThanOrEquals =>
        query.gte(filter.field, filter.value),
      FilterOperator.arrayContains =>
        query.contains(filter.field, [filter.value]),
      FilterOperator.arrayContainsAny =>
        query.overlaps(filter.field, filter.value as List),
      FilterOperator.whereIn =>
        query.inFilter(filter.field, filter.value as List),
      FilterOperator.whereNotIn =>
        throw UnimplementedError('whereNotIn not directly supported'),
      FilterOperator.isNull => query.isFilter(filter.field, null),
      FilterOperator.isNotNull => query.not(filter.field, 'is', null),
    };
  }

  bool _evaluateFilter(dynamic value, QueryFilter filter) {
    return switch (filter.operator) {
      FilterOperator.equals => value == filter.value,
      FilterOperator.notEquals => value != filter.value,
      FilterOperator.lessThan => value < filter.value,
      FilterOperator.lessThanOrEquals => value <= filter.value,
      FilterOperator.greaterThan => value > filter.value,
      FilterOperator.greaterThanOrEquals => value >= filter.value,
      FilterOperator.arrayContains =>
        (value as List?)?.contains(filter.value) ?? false,
      FilterOperator.arrayContainsAny =>
        (value as List?)?.any((e) => (filter.value as List).contains(e)) ??
            false,
      FilterOperator.whereIn => (filter.value as List).contains(value),
      FilterOperator.whereNotIn => !(filter.value as List).contains(value),
      FilterOperator.isNull => value == null,
      FilterOperator.isNotNull => value != null,
    };
  }

  String _singularize(String plural) {
    if (plural.endsWith('ies')) {
      return '${plural.substring(0, plural.length - 3)}y';
    } else if (plural.endsWith('s')) {
      return plural.substring(0, plural.length - 1);
    }
    return plural;
  }

  BackendError _mapPostgrestError(PostgrestException e) {
    final code = switch (e.code) {
      '23505' => BackendErrorCode.alreadyExists, // Unique violation
      '23503' => BackendErrorCode.invalidData, // Foreign key violation
      '42501' => BackendErrorCode.permissionDenied, // Insufficient privilege
      '42P01' => BackendErrorCode.notFound, // Table not found
      'PGRST301' => BackendErrorCode.permissionDenied, // RLS violation
      _ => BackendErrorCode.unknown,
    };
    return BackendError(
        message: e.message, code: code, details: {'code': e.code});
  }
}

/// Transaction context for Supabase (simplified)
class _SupabaseTransactionContext implements TransactionContext {
  _SupabaseTransactionContext(this._adapter);
  final SupabaseDataStoreAdapter _adapter;

  @override
  Future<Map<String, dynamic>?> get(
      String collection, String documentId) async {
    final result = await _adapter.get(collection, documentId);
    return result.dataOrNull;
  }

  @override
  void set(String collection, String documentId, Map<String, dynamic> data) {
    _adapter.set(collection, documentId, data);
  }

  @override
  void update(String collection, String documentId, Map<String, dynamic> data) {
    _adapter.update(collection, documentId, data);
  }

  @override
  void delete(String collection, String documentId) {
    _adapter.delete(collection, documentId);
  }
}
