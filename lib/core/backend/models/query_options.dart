/// Query options for data store operations.
///
/// This class provides a backend-agnostic way to specify query parameters
/// that can be translated to any database query language.
///
/// ## Usage
/// ```dart
/// final options = QueryOptions(
///   filters: [
///     QueryFilter.equals('status', 'active'),
///     QueryFilter.greaterThan('age', 18),
///   ],
///   orderBy: [
///     OrderBy('createdAt', descending: true),
///   ],
///   limit: 20,
/// );
///
/// final results = await dataStore.query('users', options);
/// ```
class QueryOptions {
  const QueryOptions({
    this.filters = const [],
    this.orderBy = const [],
    this.limit,
    this.offset,
    this.startAfter,
    this.endBefore,
  });

  /// Filter conditions
  final List<QueryFilter> filters;

  /// Ordering configuration
  final List<OrderBy> orderBy;

  /// Maximum number of results
  final int? limit;

  /// Offset for pagination
  final int? offset;

  /// Start after document (for cursor-based pagination)
  final dynamic startAfter;

  /// End before document (for cursor-based pagination)
  final dynamic endBefore;

  /// Create a copy with updated values
  QueryOptions copyWith({
    List<QueryFilter>? filters,
    List<OrderBy>? orderBy,
    int? limit,
    int? offset,
    dynamic startAfter,
    dynamic endBefore,
  }) {
    return QueryOptions(
      filters: filters ?? this.filters,
      orderBy: orderBy ?? this.orderBy,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      startAfter: startAfter ?? this.startAfter,
      endBefore: endBefore ?? this.endBefore,
    );
  }

  /// Add a filter
  QueryOptions where(String field, FilterOperator operator, dynamic value) {
    return copyWith(
      filters: [...filters, QueryFilter(field, operator, value)],
    );
  }

  /// Add ordering
  QueryOptions order(String field, {bool descending = false}) {
    return copyWith(
      orderBy: [...orderBy, OrderBy(field, descending: descending)],
    );
  }

  /// Set limit
  QueryOptions take(int count) => copyWith(limit: count);

  /// Set offset
  QueryOptions skip(int count) => copyWith(offset: count);
}

/// Query filter condition
class QueryFilter {
  const QueryFilter(this.field, this.operator, this.value);

  /// Field name to filter on
  final String field;

  /// Filter operator
  final FilterOperator operator;

  /// Value to compare against
  final dynamic value;

  // Convenience constructors
  const QueryFilter.equals(this.field, this.value)
      : operator = FilterOperator.equals;

  const QueryFilter.notEquals(this.field, this.value)
      : operator = FilterOperator.notEquals;

  const QueryFilter.lessThan(this.field, this.value)
      : operator = FilterOperator.lessThan;

  const QueryFilter.lessThanOrEquals(this.field, this.value)
      : operator = FilterOperator.lessThanOrEquals;

  const QueryFilter.greaterThan(this.field, this.value)
      : operator = FilterOperator.greaterThan;

  const QueryFilter.greaterThanOrEquals(this.field, this.value)
      : operator = FilterOperator.greaterThanOrEquals;

  const QueryFilter.contains(this.field, this.value)
      : operator = FilterOperator.arrayContains;

  const QueryFilter.inList(this.field, this.value)
      : operator = FilterOperator.whereIn;

  const QueryFilter.notInList(this.field, this.value)
      : operator = FilterOperator.whereNotIn;

  @override
  String toString() => 'QueryFilter($field ${operator.name} $value)';
}

/// Filter operators
enum FilterOperator {
  equals,
  notEquals,
  lessThan,
  lessThanOrEquals,
  greaterThan,
  greaterThanOrEquals,
  arrayContains,
  arrayContainsAny,
  whereIn,
  whereNotIn,
  isNull,
  isNotNull,
}

/// Ordering configuration
class OrderBy {
  const OrderBy(this.field, {this.descending = false});

  /// Field to order by
  final String field;

  /// Whether to order descending
  final bool descending;

  @override
  String toString() => 'OrderBy($field, ${descending ? 'desc' : 'asc'})';
}

/// Batch write operations
class BatchOperation {
  const BatchOperation._({
    required this.type,
    required this.collection,
    required this.documentId,
    this.data,
  });

  /// Create a set operation
  const factory BatchOperation.set({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) = _BatchSet;

  /// Create an update operation
  const factory BatchOperation.update({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) = _BatchUpdate;

  /// Create a delete operation
  const factory BatchOperation.delete({
    required String collection,
    required String documentId,
  }) = _BatchDelete;

  final BatchOperationType type;
  final String collection;
  final String documentId;
  final Map<String, dynamic>? data;
}

class _BatchSet extends BatchOperation {
  const _BatchSet({
    required super.collection,
    required super.documentId,
    required Map<String, dynamic> data,
  }) : super._(type: BatchOperationType.set, data: data);
}

class _BatchUpdate extends BatchOperation {
  const _BatchUpdate({
    required super.collection,
    required super.documentId,
    required Map<String, dynamic> data,
  }) : super._(type: BatchOperationType.update, data: data);
}

class _BatchDelete extends BatchOperation {
  const _BatchDelete({
    required super.collection,
    required super.documentId,
  }) : super._(type: BatchOperationType.delete, data: null);
}

enum BatchOperationType { set, update, delete }

/// Transaction callback type
typedef TransactionCallback<T> = Future<T> Function(TransactionContext context);

/// Transaction context for atomic operations
abstract class TransactionContext {
  /// Get a document within the transaction
  Future<Map<String, dynamic>?> get(String collection, String documentId);

  /// Set a document within the transaction
  void set(String collection, String documentId, Map<String, dynamic> data);

  /// Update a document within the transaction
  void update(String collection, String documentId, Map<String, dynamic> data);

  /// Delete a document within the transaction
  void delete(String collection, String documentId);
}
