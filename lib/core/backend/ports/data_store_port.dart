import '../models/backend_result.dart';
import '../models/query_options.dart';

/// Data store service port (interface).
///
/// This is the PORT in Hexagonal Architecture - it defines what the application
/// needs from a data store WITHOUT specifying how it's implemented.
///
/// ## Implementations
/// - `FirebaseDataStoreAdapter` - Firestore
/// - `SupabaseDataStoreAdapter` - Supabase Postgres (future)
/// - `MockDataStoreAdapter` - For testing
///
/// ## Design Principles
/// This interface follows:
/// - **ISP**: Segregated into logical operation groups
/// - **LSP**: Any implementation can be substituted
/// - **DIP**: Depends on abstractions, not concrete types
///
/// ## Usage
/// ```dart
/// class UserRepository {
///   final IDataStore dataStore;
///
///   UserRepository(this.dataStore);
///
///   Future<User?> getUser(String id) async {
///     final result = await dataStore.get('users', id);
///     return result.when(
///       success: (data) => data != null ? User.fromJson(data) : null,
///       failure: (error) => null,
///     );
///   }
/// }
/// ```
abstract interface class IDataStore {
  // ==================== Single Document Operations ====================
  /// Get a single document by ID
  Future<BackendResult<Map<String, dynamic>?>> get(
    String collection,
    String documentId,
  );

  /// Check if a document exists
  Future<BackendResult<bool>> exists(
    String collection,
    String documentId,
  );

  /// Create a new document with auto-generated ID
  Future<BackendResult<String>> add(
    String collection,
    Map<String, dynamic> data,
  );

  /// Create or overwrite a document with specific ID
  Future<BackendResult<void>> set(
    String collection,
    String documentId,
    Map<String, dynamic> data, {
    bool merge = false,
  });

  /// Update specific fields in a document
  Future<BackendResult<void>> update(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  );

  /// Delete a document
  Future<BackendResult<void>> delete(
    String collection,
    String documentId,
  );

  // ==================== Collection Operations ====================
  /// Query documents in a collection
  Future<BackendResult<List<Map<String, dynamic>>>> query(
    String collection, {
    QueryOptions? options,
  });

  /// Get all documents in a collection
  Future<BackendResult<List<Map<String, dynamic>>>> getAll(
    String collection, {
    int? limit,
  });

  /// Count documents matching query
  Future<BackendResult<int>> count(
    String collection, {
    QueryOptions? options,
  });

  // ==================== Subcollection Operations ====================
  /// Get a document from a subcollection
  Future<BackendResult<Map<String, dynamic>?>> getSubdocument(
    String parentCollection,
    String parentId,
    String subcollection,
    String documentId,
  );

  /// Add a document to a subcollection
  Future<BackendResult<String>> addToSubcollection(
    String parentCollection,
    String parentId,
    String subcollection,
    Map<String, dynamic> data,
  );

  /// Set a document in a subcollection
  Future<BackendResult<void>> setSubdocument(
    String parentCollection,
    String parentId,
    String subcollection,
    String documentId,
    Map<String, dynamic> data, {
    bool merge = false,
  });

  /// Query subcollection documents
  Future<BackendResult<List<Map<String, dynamic>>>> querySubcollection(
    String parentCollection,
    String parentId,
    String subcollection, {
    QueryOptions? options,
  });

  /// Delete a subcollection document
  Future<BackendResult<void>> deleteSubdocument(
    String parentCollection,
    String parentId,
    String subcollection,
    String documentId,
  );

  // ==================== Batch Operations ====================
  /// Execute multiple operations atomically
  Future<BackendResult<void>> batch(List<BatchOperation> operations);

  // ==================== Transactions ====================
  /// Execute operations in a transaction
  Future<BackendResult<T>> runTransaction<T>(
    TransactionCallback<T> callback,
  );

  // ==================== Real-time Streams ====================
  /// Stream a document's changes
  Stream<BackendResult<Map<String, dynamic>?>> streamDocument(
    String collection,
    String documentId,
  );

  /// Stream query results
  Stream<BackendResult<List<Map<String, dynamic>>>> streamQuery(
    String collection, {
    QueryOptions? options,
  });

  /// Stream subcollection documents
  Stream<BackendResult<List<Map<String, dynamic>>>> streamSubcollection(
    String parentCollection,
    String parentId,
    String subcollection, {
    QueryOptions? options,
  });

  // ==================== Field Operations ====================
  /// Increment a numeric field
  Future<BackendResult<void>> increment(
    String collection,
    String documentId,
    String field,
    num value,
  );

  /// Add to an array field
  Future<BackendResult<void>> arrayUnion(
    String collection,
    String documentId,
    String field,
    List<dynamic> values,
  );

  /// Remove from an array field
  Future<BackendResult<void>> arrayRemove(
    String collection,
    String documentId,
    String field,
    List<dynamic> values,
  );

  /// Set server timestamp
  Future<BackendResult<void>> setServerTimestamp(
    String collection,
    String documentId,
    String field,
  );
}
