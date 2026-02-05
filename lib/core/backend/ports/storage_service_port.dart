import 'dart:typed_data';

import '../models/backend_result.dart';

/// Storage service port (interface).
///
/// This is the PORT in Hexagonal Architecture - it defines what the application
/// needs from file storage WITHOUT specifying how it's implemented.
///
/// ## Implementations
/// - `FirebaseStorageAdapter` - Firebase Storage
/// - `SupabaseStorageAdapter` - Supabase Storage (future)
/// - `S3StorageAdapter` - AWS S3 (future)
/// - `MockStorageAdapter` - For testing
///
/// ## Usage
/// ```dart
/// class ProfileService {
///   final IStorageService storage;
///
///   ProfileService(this.storage);
///
///   Future<String?> uploadAvatar(Uint8List imageData) async {
///     final result = await storage.upload(
///       path: 'avatars/${userId}.jpg',
///       data: imageData,
///       contentType: 'image/jpeg',
///     );
///     return result.dataOrNull;
///   }
/// }
/// ```
abstract interface class IStorageService {
  // ==================== Upload Operations ====================
  /// Upload data to storage
  Future<BackendResult<String>> upload({
    required String path,
    required Uint8List data,
    String? contentType,
    Map<String, String>? metadata,
    void Function(double progress)? onProgress,
  });

  /// Upload from file path (mobile/desktop)
  Future<BackendResult<String>> uploadFile({
    required String path,
    required String filePath,
    String? contentType,
    Map<String, String>? metadata,
    void Function(double progress)? onProgress,
  });

  /// Upload from stream
  Future<BackendResult<String>> uploadStream({
    required String path,
    required Stream<List<int>> data,
    required int length,
    String? contentType,
    Map<String, String>? metadata,
    void Function(double progress)? onProgress,
  });

  // ==================== Download Operations ====================
  /// Download data from storage
  Future<BackendResult<Uint8List>> download(String path);

  /// Get download URL
  Future<BackendResult<String>> getDownloadUrl(String path);

  /// Stream download progress
  Stream<DownloadProgress> downloadWithProgress(String path);

  // ==================== File Operations ====================
  /// Delete a file
  Future<BackendResult<void>> delete(String path);

  /// Move/rename a file
  Future<BackendResult<void>> move({
    required String fromPath,
    required String toPath,
  });

  /// Copy a file
  Future<BackendResult<void>> copy({
    required String fromPath,
    required String toPath,
  });

  /// Check if file exists
  Future<BackendResult<bool>> exists(String path);

  // ==================== Metadata Operations ====================
  /// Get file metadata
  Future<BackendResult<StorageMetadata>> getMetadata(String path);

  /// Update file metadata
  Future<BackendResult<void>> updateMetadata(
    String path,
    Map<String, String> metadata,
  );

  // ==================== List Operations ====================
  /// List files in a directory
  Future<BackendResult<List<StorageItem>>> list({
    String? path,
    int? maxResults,
    String? pageToken,
  });

  /// List all files recursively
  Future<BackendResult<List<StorageItem>>> listAll(String? path);
}

/// Storage file metadata
class StorageMetadata {
  const StorageMetadata({
    required this.path,
    required this.name,
    this.size,
    this.contentType,
    this.createdAt,
    this.updatedAt,
    this.customMetadata = const {},
    this.downloadUrl,
  });

  /// Full path to the file
  final String path;

  /// File name
  final String name;

  /// File size in bytes
  final int? size;

  /// Content type (MIME type)
  final String? contentType;

  /// Creation timestamp
  final DateTime? createdAt;

  /// Last update timestamp
  final DateTime? updatedAt;

  /// Custom metadata
  final Map<String, String> customMetadata;

  /// Download URL (if available)
  final String? downloadUrl;
}

/// Storage item (file or folder)
class StorageItem {
  const StorageItem({
    required this.path,
    required this.name,
    required this.isFile,
    this.size,
    this.contentType,
    this.updatedAt,
  });

  /// Full path
  final String path;

  /// Item name
  final String name;

  /// Whether this is a file (false = folder)
  final bool isFile;

  /// File size (only for files)
  final int? size;

  /// Content type (only for files)
  final String? contentType;

  /// Last update timestamp
  final DateTime? updatedAt;

  bool get isFolder => !isFile;
}

/// Download progress information
class DownloadProgress {
  const DownloadProgress({
    required this.bytesDownloaded,
    required this.totalBytes,
    this.data,
  });

  /// Bytes downloaded so far
  final int bytesDownloaded;

  /// Total bytes to download (-1 if unknown)
  final int totalBytes;

  /// Downloaded data (only set when complete)
  final Uint8List? data;

  /// Progress percentage (0.0 to 1.0)
  double get progress => totalBytes > 0 ? bytesDownloaded / totalBytes : 0.0;

  /// Whether download is complete
  bool get isComplete => data != null;
}
