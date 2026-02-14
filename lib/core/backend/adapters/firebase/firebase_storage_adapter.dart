import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart' as fbs;

import '../../models/backend_result.dart';
import '../../ports/storage_service_port.dart';

/// Firebase Storage adapter.
///
/// This is the ADAPTER in Hexagonal Architecture - it implements the
/// [IStorageService] port using Firebase Storage.
class FirebaseStorageAdapter implements IStorageService {
  FirebaseStorageAdapter({
    fbs.FirebaseStorage? storage,
  }) : _storage = storage ?? fbs.FirebaseStorage.instance;

  final fbs.FirebaseStorage _storage;

  // ==================== Upload Operations ====================
  @override
  Future<BackendResult<String>> upload({
    required String path,
    required Uint8List data,
    String? contentType,
    Map<String, String>? metadata,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final ref = _storage.ref(path);
      final uploadTask = ref.putData(
        data,
        fbs.SettableMetadata(
          contentType: contentType,
          customMetadata: metadata,
        ),
      );

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((event) {
          final progress = event.bytesTransferred / event.totalBytes;
          onProgress(progress);
        });
      }

      await uploadTask;
      final downloadUrl = await ref.getDownloadURL();
      return BackendResult.success(downloadUrl);
    } on fbs.FirebaseException catch (e) {
      return BackendResult.failure(_mapStorageError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
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
    // This requires dart:io which is not available on web
    // For cross-platform, use upload() with Uint8List instead
    return const BackendResult.failure(BackendError(
      code: BackendErrorCode.invalidData,
      message:
          'uploadFile not supported on this platform. Use upload() instead.',
    ));
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
      final ref = _storage.ref(path);
      final uploadTask = ref.putBlob(
        await _streamToBlob(data, length),
      );

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((event) {
          final progress = event.bytesTransferred / event.totalBytes;
          onProgress(progress);
        });
      }

      await uploadTask;
      final downloadUrl = await ref.getDownloadURL();
      return BackendResult.success(downloadUrl);
    } on fbs.FirebaseException catch (e) {
      return BackendResult.failure(_mapStorageError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  // Helper to convert stream to blob
  Future<dynamic> _streamToBlob(Stream<List<int>> stream, int length) async {
    final bytes = <int>[];
    await for (final chunk in stream) {
      bytes.addAll(chunk);
    }
    return Uint8List.fromList(bytes);
  }

  // ==================== Download Operations ====================
  @override
  Future<BackendResult<Uint8List>> download(String path) async {
    try {
      final ref = _storage.ref(path);
      final data = await ref.getData();
      if (data == null) {
        return const BackendResult.failure(BackendError(
          code: BackendErrorCode.notFound,
          message: 'File not found',
        ));
      }
      return BackendResult.success(data);
    } on fbs.FirebaseException catch (e) {
      return BackendResult.failure(_mapStorageError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<String>> getDownloadUrl(String path) async {
    try {
      final ref = _storage.ref(path);
      final url = await ref.getDownloadURL();
      return BackendResult.success(url);
    } on fbs.FirebaseException catch (e) {
      return BackendResult.failure(_mapStorageError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Stream<DownloadProgress> downloadWithProgress(String path) async* {
    try {
      final ref = _storage.ref(path);
      final metadata = await ref.getMetadata();
      final totalBytes = metadata.size ?? -1;

      final data = await ref.getData();
      yield DownloadProgress(
        bytesDownloaded: data?.length ?? 0,
        totalBytes: totalBytes,
        data: data,
      );
    } on Object {
      yield const DownloadProgress(
        bytesDownloaded: 0,
        totalBytes: -1,
      );
    }
  }

  // ==================== File Operations ====================
  @override
  Future<BackendResult<void>> delete(String path) async {
    try {
      await _storage.ref(path).delete();
      return const BackendResult.success(null);
    } on fbs.FirebaseException catch (e) {
      return BackendResult.failure(_mapStorageError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> move({
    required String fromPath,
    required String toPath,
  }) async {
    try {
      // Firebase Storage doesn't have native move, so copy then delete
      final data = await _storage.ref(fromPath).getData();
      if (data == null) {
        return const BackendResult.failure(BackendError(
          code: BackendErrorCode.notFound,
          message: 'Source file not found',
        ));
      }

      await _storage.ref(toPath).putData(data);
      await _storage.ref(fromPath).delete();

      return const BackendResult.success(null);
    } on fbs.FirebaseException catch (e) {
      return BackendResult.failure(_mapStorageError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> copy({
    required String fromPath,
    required String toPath,
  }) async {
    try {
      final data = await _storage.ref(fromPath).getData();
      if (data == null) {
        return const BackendResult.failure(BackendError(
          code: BackendErrorCode.notFound,
          message: 'Source file not found',
        ));
      }

      await _storage.ref(toPath).putData(data);
      return const BackendResult.success(null);
    } on fbs.FirebaseException catch (e) {
      return BackendResult.failure(_mapStorageError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<bool>> exists(String path) async {
    try {
      await _storage.ref(path).getMetadata();
      return const BackendResult.success(true);
    } on fbs.FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return const BackendResult.success(false);
      }
      return BackendResult.failure(_mapStorageError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  // ==================== Metadata Operations ====================
  @override
  Future<BackendResult<StorageMetadata>> getMetadata(String path) async {
    try {
      final ref = _storage.ref(path);
      final meta = await ref.getMetadata();
      final url = await ref.getDownloadURL();

      return BackendResult.success(StorageMetadata(
        path: meta.fullPath,
        name: meta.name,
        size: meta.size,
        contentType: meta.contentType,
        createdAt: meta.timeCreated,
        updatedAt: meta.updated,
        customMetadata: meta.customMetadata ?? {},
        downloadUrl: url,
      ));
    } on fbs.FirebaseException catch (e) {
      return BackendResult.failure(_mapStorageError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> updateMetadata(
    String path,
    Map<String, String> metadata,
  ) async {
    try {
      await _storage.ref(path).updateMetadata(
            fbs.SettableMetadata(customMetadata: metadata),
          );
      return const BackendResult.success(null);
    } on fbs.FirebaseException catch (e) {
      return BackendResult.failure(_mapStorageError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  // ==================== List Operations ====================
  @override
  Future<BackendResult<List<StorageItem>>> list({
    String? path,
    int? maxResults,
    String? pageToken,
  }) async {
    try {
      final ref = path != null ? _storage.ref(path) : _storage.ref();
      final result = await ref.list(
        fbs.ListOptions(
          maxResults: maxResults ?? 100,
          pageToken: pageToken,
        ),
      );

      final items = <StorageItem>[];

      // Add folders (prefixes)
      for (final prefix in result.prefixes) {
        items.add(StorageItem(
          path: prefix.fullPath,
          name: prefix.name,
          isFile: false,
        ));
      }

      // Add files
      for (final item in result.items) {
        items.add(StorageItem(
          path: item.fullPath,
          name: item.name,
          isFile: true,
        ));
      }

      return BackendResult.success(items);
    } on fbs.FirebaseException catch (e) {
      return BackendResult.failure(_mapStorageError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<List<StorageItem>>> listAll(String? path) async {
    try {
      final ref = path != null ? _storage.ref(path) : _storage.ref();
      final result = await ref.listAll();

      final items = <StorageItem>[];

      // Add folders (prefixes)
      for (final prefix in result.prefixes) {
        items.add(StorageItem(
          path: prefix.fullPath,
          name: prefix.name,
          isFile: false,
        ));
      }

      // Add files
      for (final item in result.items) {
        items.add(StorageItem(
          path: item.fullPath,
          name: item.name,
          isFile: true,
        ));
      }

      return BackendResult.success(items);
    } on fbs.FirebaseException catch (e) {
      return BackendResult.failure(_mapStorageError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  // ==================== Private Helpers ====================
  BackendError _mapStorageError(fbs.FirebaseException e) {
    final code = switch (e.code) {
      'object-not-found' => BackendErrorCode.notFound,
      'unauthorized' => BackendErrorCode.permissionDenied,
      'canceled' => BackendErrorCode.authError,
      'quota-exceeded' => BackendErrorCode.storageFull,
      _ => BackendErrorCode.serverError,
    };

    return BackendError(
      code: code,
      message: e.message ?? e.code,
      details: {'storageCode': e.code},
    );
  }
}
