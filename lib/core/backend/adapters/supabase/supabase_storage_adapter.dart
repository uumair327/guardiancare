import 'package:flutter/foundation.dart';
import 'package:guardiancare/core/util/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/backend_result.dart';
import '../../ports/storage_service_port.dart';
import 'supabase_initializer.dart';

/// Supabase implementation of [IStorageService].
///
/// This adapter implements file storage using Supabase Storage.
///
/// ## Key Differences from Firebase Storage
///
/// | Firebase Storage | Supabase Storage |
/// |------------------|------------------|
/// | References | Buckets + paths |
/// | Auto-generated URLs | Signed URLs |
/// | Security Rules | RLS policies |
///
/// ## Setup Required
///
/// 1. Create storage buckets in Supabase Dashboard
/// 2. Configure RLS policies for each bucket
/// 3. Set appropriate file size limits
///
/// ## Bucket Naming Convention
/// Default bucket: 'public' (for public files)
/// Other buckets: 'avatars', 'documents', etc.
class SupabaseStorageAdapter implements IStorageService {
  SupabaseStorageAdapter({String? defaultBucket})
      : _client = SupabaseInitializer.client,
        _defaultBucket = defaultBucket ?? 'public' {
    Log.d('SupabaseStorageAdapter: Initialized with bucket $_defaultBucket');
  }

  final SupabaseClient _client;
  final String _defaultBucket;

  SupabaseStorageClient get _storage => _client.storage;

  /// Extract bucket from path or use default
  /// Path format: "bucket/path/to/file" or just "path/to/file"
  (String bucket, String path) _parsePath(String fullPath) {
    final parts = fullPath.split('/');
    if (parts.length > 1 && _isKnownBucket(parts.first)) {
      return (parts.first, parts.skip(1).join('/'));
    }
    return (_defaultBucket, fullPath);
  }

  bool _isKnownBucket(String name) {
    return ['public', 'avatars', 'documents', 'images', 'videos']
        .contains(name);
  }

  // ============================================================================
  // Upload Operations
  // ============================================================================

  @override
  Future<BackendResult<String>> upload({
    required String path,
    required Uint8List data,
    String? contentType,
    Map<String, String>? metadata,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final (bucket, filePath) = _parsePath(path);

      await _storage.from(bucket).uploadBinary(
            filePath,
            data,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: true,
            ),
          );

      // Get public URL
      final url = _storage.from(bucket).getPublicUrl(filePath);
      onProgress?.call(1);

      return BackendResult.success(url);
    } on StorageException catch (e) {
      return BackendResult.failure(_mapStorageError(e));
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<String>> uploadFile({
    required String path,
    required String filePath,
    String? contentType,
    Map<String, String>? metadata,
    void Function(double progress)? onProgress,
  }) async {
    // For Flutter, we typically use bytes rather than file paths
    // This would require reading the file first in a platform-specific way
    return const BackendResult.failure(
      BackendError(
        message: 'Use upload() with Uint8List instead',
        code: BackendErrorCode.operationNotAllowed,
      ),
    );
  }

  @override
  Future<BackendResult<String>> uploadStream({
    required String path,
    required Stream<List<int>> data,
    required int length,
    String? contentType,
    Map<String, String>? metadata,
    void Function(double progress)? onProgress,
  }) async {
    try {
      // Collect stream into bytes
      final bytes = await _collectStreamToBytes(data);
      return upload(
        path: path,
        data: bytes,
        contentType: contentType,
        metadata: metadata,
        onProgress: onProgress,
      );
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  Future<Uint8List> _collectStreamToBytes(Stream<List<int>> stream) async {
    final chunks = <int>[];
    await for (final chunk in stream) {
      chunks.addAll(chunk);
    }
    return Uint8List.fromList(chunks);
  }

  // ============================================================================
  // Download Operations
  // ============================================================================

  @override
  Future<BackendResult<Uint8List>> download(String path) async {
    try {
      final (bucket, filePath) = _parsePath(path);
      final data = await _storage.from(bucket).download(filePath);
      return BackendResult.success(data);
    } on StorageException catch (e) {
      return BackendResult.failure(_mapStorageError(e));
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<String>> getDownloadUrl(String path) async {
    try {
      final (bucket, filePath) = _parsePath(path);

      // For public buckets, use public URL
      // For private buckets, create signed URL
      final url = _storage.from(bucket).getPublicUrl(filePath);
      return BackendResult.success(url);
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  /// Get a signed URL for private files
  Future<BackendResult<String>> getSignedUrl(
    String path, {
    Duration expiry = const Duration(hours: 1),
  }) async {
    try {
      final (bucket, filePath) = _parsePath(path);
      final url = await _storage
          .from(bucket)
          .createSignedUrl(filePath, expiry.inSeconds);
      return BackendResult.success(url);
    } on StorageException catch (e) {
      return BackendResult.failure(_mapStorageError(e));
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Stream<DownloadProgress> downloadWithProgress(String path) async* {
    try {
      final (bucket, filePath) = _parsePath(path);

      // Supabase doesn't have built-in progress tracking
      // Yield start, then download, then complete
      yield const DownloadProgress(
        bytesDownloaded: 0,
        totalBytes: -1,
      );

      final data = await _storage.from(bucket).download(filePath);

      yield DownloadProgress(
        bytesDownloaded: data.length,
        totalBytes: data.length,
        data: data,
      );
    } on Object {
      // Yield an empty progress to indicate error
      yield const DownloadProgress(
        bytesDownloaded: 0,
        totalBytes: 0,
      );
    }
  }

  // ============================================================================
  // File Management
  // ============================================================================

  @override
  Future<BackendResult<void>> delete(String path) async {
    try {
      final (bucket, filePath) = _parsePath(path);
      await _storage.from(bucket).remove([filePath]);
      return const BackendResult.success(null);
    } on StorageException catch (e) {
      return BackendResult.failure(_mapStorageError(e));
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<void>> move({
    required String fromPath,
    required String toPath,
  }) async {
    try {
      final (fromBucket, fromFile) = _parsePath(fromPath);
      final (toBucket, toFile) = _parsePath(toPath);

      if (fromBucket == toBucket) {
        await _storage.from(fromBucket).move(fromFile, toFile);
      } else {
        // Cross-bucket move: download, upload, delete
        final data = await _storage.from(fromBucket).download(fromFile);
        await _storage.from(toBucket).uploadBinary(toFile, data);
        await _storage.from(fromBucket).remove([fromFile]);
      }

      return const BackendResult.success(null);
    } on StorageException catch (e) {
      return BackendResult.failure(_mapStorageError(e));
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<void>> copy({
    required String fromPath,
    required String toPath,
  }) async {
    try {
      final (fromBucket, fromFile) = _parsePath(fromPath);
      final (toBucket, toFile) = _parsePath(toPath);

      if (fromBucket == toBucket) {
        await _storage.from(fromBucket).copy(fromFile, toFile);
      } else {
        // Cross-bucket copy: download and upload
        final data = await _storage.from(fromBucket).download(fromFile);
        await _storage.from(toBucket).uploadBinary(toFile, data);
      }

      return const BackendResult.success(null);
    } on StorageException catch (e) {
      return BackendResult.failure(_mapStorageError(e));
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<bool>> exists(String path) async {
    try {
      final (bucket, filePath) = _parsePath(path);
      final folder = filePath.contains('/')
          ? filePath.substring(0, filePath.lastIndexOf('/'))
          : '';
      final fileName = filePath.split('/').last;

      final files = await _storage.from(bucket).list(path: folder);
      final exists = files.any((f) => f.name == fileName);

      return BackendResult.success(exists);
    } on Object {
      return const BackendResult.success(false);
    }
  }

  // ============================================================================
  // Metadata
  // ============================================================================

  @override
  Future<BackendResult<StorageMetadata>> getMetadata(String path) async {
    try {
      final (bucket, filePath) = _parsePath(path);
      final folder = filePath.contains('/')
          ? filePath.substring(0, filePath.lastIndexOf('/'))
          : '';
      final fileName = filePath.split('/').last;

      final files = await _storage.from(bucket).list(path: folder);
      final file = files.firstWhere(
        (f) => f.name == fileName,
        orElse: () => throw Exception('File not found'),
      );

      return BackendResult.success(StorageMetadata(
        path: path,
        name: file.name,
        size: file.metadata?['size'] as int?,
        contentType: file.metadata?['mimetype'] as String?,
        updatedAt: DateTime.tryParse(file.updatedAt ?? ''),
      ));
    } on StorageException catch (e) {
      return BackendResult.failure(_mapStorageError(e));
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.notFound),
      );
    }
  }

  @override
  Future<BackendResult<void>> updateMetadata(
    String path,
    Map<String, String> metadata,
  ) async {
    // Supabase Storage doesn't support custom metadata updates
    // Metadata is set during upload
    return const BackendResult.failure(
      BackendError(
        message: 'Supabase does not support metadata updates',
        code: BackendErrorCode.operationNotAllowed,
      ),
    );
  }

  // ============================================================================
  // Listing
  // ============================================================================

  @override
  Future<BackendResult<List<StorageItem>>> list({
    String? path,
    int? maxResults,
    String? pageToken,
  }) async {
    try {
      final (bucket, folderPath) = _parsePath(path ?? '');
      final files = await _storage.from(bucket).list(
            path: folderPath.isEmpty ? null : folderPath,
            searchOptions: SearchOptions(
              limit: maxResults ?? 100,
              offset: int.tryParse(pageToken ?? '0') ?? 0,
            ),
          );

      final items = files
          .map((f) => StorageItem(
                name: f.name,
                path: folderPath.isEmpty ? f.name : '$folderPath/${f.name}',
                isFile: f.id != null,
                size: f.metadata?['size'] as int?,
                updatedAt: DateTime.tryParse(f.updatedAt ?? ''),
              ))
          .toList();

      return BackendResult.success(items);
    } on StorageException catch (e) {
      return BackendResult.failure(_mapStorageError(e));
    } on Object catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<List<StorageItem>>> listAll(String? path) async {
    // Recursively list all files
    final allItems = <StorageItem>[];
    var offset = 0;
    const batchSize = 100;

    while (true) {
      final result = await list(
        path: path,
        maxResults: batchSize,
        pageToken: offset.toString(),
      );

      if (result.isFailure) return result;

      final items = result.dataOrNull ?? [];
      allItems.addAll(items);

      if (items.length < batchSize) break;
      offset += batchSize;
    }

    return BackendResult.success(allItems);
  }

  // ============================================================================
  // Helpers
  // ============================================================================

  BackendError _mapStorageError(StorageException e) {
    final code = switch (e.statusCode) {
      '404' => BackendErrorCode.notFound,
      '403' => BackendErrorCode.permissionDenied,
      '413' => BackendErrorCode.fileTooLarge,
      '507' => BackendErrorCode.storageFull,
      _ => BackendErrorCode.unknown,
    };
    return BackendError(message: e.message, code: code);
  }
}
