import 'package:cloud_firestore/cloud_firestore.dart' as fs;

import '../../models/backend_result.dart';
import '../../models/query_options.dart';
import '../../ports/data_store_port.dart';

/// Firestore data store adapter.
///
/// This is the ADAPTER in Hexagonal Architecture - it implements the
/// [IDataStore] port using Firebase Firestore.
///
/// ## Switching to Another Provider
/// To switch to Supabase, create a `SupabaseDataStoreAdapter` that implements
/// [IDataStore] and register it in the dependency injection container.
class FirebaseDataStoreAdapter implements IDataStore {
  FirebaseDataStoreAdapter({
    fs.FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? fs.FirebaseFirestore.instance;

  final fs.FirebaseFirestore _firestore;

  // ==================== Single Document Operations ====================
  @override
  Future<BackendResult<Map<String, dynamic>?>> get(
    String collection,
    String documentId,
  ) async {
    try {
      final doc = await _firestore.collection(collection).doc(documentId).get();
      return BackendResult.success(doc.exists ? doc.data() : null);
    } on fs.FirebaseException catch (e) {
      return BackendResult.failure(_mapFirestoreError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<bool>> exists(
    String collection,
    String documentId,
  ) async {
    try {
      final doc = await _firestore.collection(collection).doc(documentId).get();
      return BackendResult.success(doc.exists);
    } on fs.FirebaseException catch (e) {
      return BackendResult.failure(_mapFirestoreError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<String>> add(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      final docRef = await _firestore.collection(collection).add(data);
      return BackendResult.success(docRef.id);
    } on fs.FirebaseException catch (e) {
      return BackendResult.failure(_mapFirestoreError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
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
      await _firestore
          .collection(collection)
          .doc(documentId)
          .set(data, fs.SetOptions(merge: merge));
      return const BackendResult.success(null);
    } on fs.FirebaseException catch (e) {
      return BackendResult.failure(_mapFirestoreError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> update(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);
      return const BackendResult.success(null);
    } on fs.FirebaseException catch (e) {
      return BackendResult.failure(_mapFirestoreError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> delete(
    String collection,
    String documentId,
  ) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
      return const BackendResult.success(null);
    } on fs.FirebaseException catch (e) {
      return BackendResult.failure(_mapFirestoreError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  // ==================== Collection Operations ====================
  @override
  Future<BackendResult<List<Map<String, dynamic>>>> query(
    String collection, {
    QueryOptions? options,
  }) async {
    try {
      fs.Query<Map<String, dynamic>> query = _firestore.collection(collection);
      query = _applyQueryOptions(query, options);

      final snapshot = await query.get();
      final results = snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();

      return BackendResult.success(results);
    } on fs.FirebaseException catch (e) {
      return BackendResult.failure(_mapFirestoreError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<List<Map<String, dynamic>>>> getAll(
    String collection, {
    int? limit,
  }) async {
    return query(
      collection,
      options: limit != null ? QueryOptions(limit: limit) : null,
    );
  }

  @override
  Future<BackendResult<int>> count(
    String collection, {
    QueryOptions? options,
  }) async {
    try {
      fs.Query<Map<String, dynamic>> query = _firestore.collection(collection);
      query = _applyQueryOptions(query, options);

      final countQuery = await query.count().get();
      return BackendResult.success(countQuery.count ?? 0);
    } on fs.FirebaseException catch (e) {
      return BackendResult.failure(_mapFirestoreError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  // ==================== Subcollection Operations ====================
  @override
  Future<BackendResult<Map<String, dynamic>?>> getSubdocument(
    String parentCollection,
    String parentId,
    String subcollection,
    String documentId,
  ) async {
    try {
      final doc = await _firestore
          .collection(parentCollection)
          .doc(parentId)
          .collection(subcollection)
          .doc(documentId)
          .get();
      return BackendResult.success(doc.exists ? doc.data() : null);
    } on fs.FirebaseException catch (e) {
      return BackendResult.failure(_mapFirestoreError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
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
      final docRef = await _firestore
          .collection(parentCollection)
          .doc(parentId)
          .collection(subcollection)
          .add(data);
      return BackendResult.success(docRef.id);
    } on fs.FirebaseException catch (e) {
      return BackendResult.failure(_mapFirestoreError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
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
      await _firestore
          .collection(parentCollection)
          .doc(parentId)
          .collection(subcollection)
          .doc(documentId)
          .set(data, fs.SetOptions(merge: merge));
      return const BackendResult.success(null);
    } on fs.FirebaseException catch (e) {
      return BackendResult.failure(_mapFirestoreError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
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
      fs.Query<Map<String, dynamic>> query = _firestore
          .collection(parentCollection)
          .doc(parentId)
          .collection(subcollection);
      query = _applyQueryOptions(query, options);

      final snapshot = await query.get();
      final results = snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();

      return BackendResult.success(results);
    } on fs.FirebaseException catch (e) {
      return BackendResult.failure(_mapFirestoreError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
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
      await _firestore
          .collection(parentCollection)
          .doc(parentId)
          .collection(subcollection)
          .doc(documentId)
          .delete();
      return const BackendResult.success(null);
    } on fs.FirebaseException catch (e) {
      return BackendResult.failure(_mapFirestoreError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  // ==================== Batch Operations ====================
  @override
  Future<BackendResult<void>> batch(List<BatchOperation> operations) async {
    try {
      final batch = _firestore.batch();

      for (final op in operations) {
        final docRef = _firestore.collection(op.collection).doc(op.documentId);

        switch (op.type) {
          case BatchOperationType.set:
            batch.set(docRef, op.data!);
            break;
          case BatchOperationType.update:
            batch.update(docRef, op.data!);
            break;
          case BatchOperationType.delete:
            batch.delete(docRef);
            break;
        }
      }

      await batch.commit();
      return const BackendResult.success(null);
    } on fs.FirebaseException catch (e) {
      return BackendResult.failure(_mapFirestoreError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  // ==================== Transactions ====================
  @override
  Future<BackendResult<T>> runTransaction<T>(
    TransactionCallback<T> callback,
  ) async {
    try {
      final result = await _firestore.runTransaction((transaction) async {
        final context = _FirebaseTransactionContext(_firestore, transaction);
        return callback(context);
      });
      return BackendResult.success(result);
    } on fs.FirebaseException catch (e) {
      return BackendResult.failure(_mapFirestoreError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  // ==================== Real-time Streams ====================
  @override
  Stream<BackendResult<Map<String, dynamic>?>> streamDocument(
    String collection,
    String documentId,
  ) {
    return _firestore
        .collection(collection)
        .doc(documentId)
        .snapshots()
        .map((doc) => BackendResult.success(doc.exists ? doc.data() : null))
        .handleError((e) => BackendResult.failure(
              BackendError.fromException(e),
            ));
  }

  @override
  Stream<BackendResult<List<Map<String, dynamic>>>> streamQuery(
    String collection, {
    QueryOptions? options,
  }) {
    fs.Query<Map<String, dynamic>> query = _firestore.collection(collection);
    query = _applyQueryOptions(query, options);

    return query.snapshots().map((snapshot) {
      final results = snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();
      return BackendResult.success(results);
    }).handleError((e) => BackendResult.failure(
          BackendError.fromException(e),
        ));
  }

  @override
  Stream<BackendResult<List<Map<String, dynamic>>>> streamSubcollection(
    String parentCollection,
    String parentId,
    String subcollection, {
    QueryOptions? options,
  }) {
    fs.Query<Map<String, dynamic>> query = _firestore
        .collection(parentCollection)
        .doc(parentId)
        .collection(subcollection);
    query = _applyQueryOptions(query, options);

    return query.snapshots().map((snapshot) {
      final results = snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();
      return BackendResult.success(results);
    }).handleError((e) => BackendResult.failure(
          BackendError.fromException(e),
        ));
  }

  // ==================== Field Operations ====================
  @override
  Future<BackendResult<void>> increment(
    String collection,
    String documentId,
    String field,
    num value,
  ) async {
    try {
      await _firestore.collection(collection).doc(documentId).update({
        field: fs.FieldValue.increment(value),
      });
      return const BackendResult.success(null);
    } on fs.FirebaseException catch (e) {
      return BackendResult.failure(_mapFirestoreError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
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
      await _firestore.collection(collection).doc(documentId).update({
        field: fs.FieldValue.arrayUnion(values),
      });
      return const BackendResult.success(null);
    } on fs.FirebaseException catch (e) {
      return BackendResult.failure(_mapFirestoreError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
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
      await _firestore.collection(collection).doc(documentId).update({
        field: fs.FieldValue.arrayRemove(values),
      });
      return const BackendResult.success(null);
    } on fs.FirebaseException catch (e) {
      return BackendResult.failure(_mapFirestoreError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> setServerTimestamp(
    String collection,
    String documentId,
    String field,
  ) async {
    try {
      await _firestore.collection(collection).doc(documentId).update({
        field: fs.FieldValue.serverTimestamp(),
      });
      return const BackendResult.success(null);
    } on fs.FirebaseException catch (e) {
      return BackendResult.failure(_mapFirestoreError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  // ==================== Private Helpers ====================
  fs.Query<Map<String, dynamic>> _applyQueryOptions(
    fs.Query<Map<String, dynamic>> query,
    QueryOptions? options,
  ) {
    if (options == null) return query;

    var modifiedQuery = query;

    // Apply filters
    for (final filter in options.filters) {
      modifiedQuery = _applyFilter(modifiedQuery, filter);
    }

    // Apply ordering
    for (final order in options.orderBy) {
      modifiedQuery = modifiedQuery.orderBy(order.field, descending: order.descending);
    }

    // Apply limit
    if (options.limit != null) {
      modifiedQuery = modifiedQuery.limit(options.limit!);
    }

    // Apply offset (Firestore doesn't have offset, use startAfter instead)
    if (options.startAfter != null) {
      modifiedQuery = modifiedQuery.startAfter([options.startAfter]);
    }

    return modifiedQuery;
  }

  fs.Query<Map<String, dynamic>> _applyFilter(
    fs.Query<Map<String, dynamic>> query,
    QueryFilter filter,
  ) {
    return switch (filter.operator) {
      FilterOperator.equals =>
        query.where(filter.field, isEqualTo: filter.value),
      FilterOperator.notEquals =>
        query.where(filter.field, isNotEqualTo: filter.value),
      FilterOperator.lessThan =>
        query.where(filter.field, isLessThan: filter.value),
      FilterOperator.lessThanOrEquals =>
        query.where(filter.field, isLessThanOrEqualTo: filter.value),
      FilterOperator.greaterThan =>
        query.where(filter.field, isGreaterThan: filter.value),
      FilterOperator.greaterThanOrEquals =>
        query.where(filter.field, isGreaterThanOrEqualTo: filter.value),
      FilterOperator.arrayContains =>
        query.where(filter.field, arrayContains: filter.value),
      FilterOperator.arrayContainsAny =>
        query.where(filter.field, arrayContainsAny: filter.value as List),
      FilterOperator.whereIn =>
        query.where(filter.field, whereIn: filter.value as List),
      FilterOperator.whereNotIn =>
        query.where(filter.field, whereNotIn: filter.value as List),
      FilterOperator.isNull => query.where(filter.field, isNull: true),
      FilterOperator.isNotNull => query.where(filter.field, isNull: false),
    };
  }

  BackendError _mapFirestoreError(fs.FirebaseException e) {
    final code = switch (e.code) {
      'permission-denied' => BackendErrorCode.permissionDenied,
      'not-found' => BackendErrorCode.notFound,
      'already-exists' => BackendErrorCode.alreadyExists,
      'unavailable' => BackendErrorCode.serviceUnavailable,
      'deadline-exceeded' => BackendErrorCode.timeout,
      _ => BackendErrorCode.serverError,
    };

    return BackendError(
      code: code,
      message: e.message ?? e.code,
      details: {'firestoreCode': e.code},
    );
  }
}

/// Firebase transaction context
class _FirebaseTransactionContext implements TransactionContext {
  _FirebaseTransactionContext(this._firestore, this._transaction);

  final fs.FirebaseFirestore _firestore;
  final fs.Transaction _transaction;

  @override
  Future<Map<String, dynamic>?> get(
    String collection,
    String documentId,
  ) async {
    final doc = await _transaction.get(
      _firestore.collection(collection).doc(documentId),
    );
    return doc.exists ? doc.data() : null;
  }

  @override
  void set(String collection, String documentId, Map<String, dynamic> data) {
    _transaction.set(
      _firestore.collection(collection).doc(documentId),
      data,
    );
  }

  @override
  void update(String collection, String documentId, Map<String, dynamic> data) {
    _transaction.update(
      _firestore.collection(collection).doc(documentId),
      data,
    );
  }

  @override
  void delete(String collection, String documentId) {
    _transaction.delete(
      _firestore.collection(collection).doc(documentId),
    );
  }
}
