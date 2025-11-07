import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Network manager for handling connectivity and offline scenarios
class NetworkManager extends ChangeNotifier {
  static NetworkManager? _instance;
  
  NetworkManager._();
  
  static NetworkManager get instance {
    _instance ??= NetworkManager._();
    return _instance!;
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  ConnectivityResult _currentConnectivity = ConnectivityResult.none;
  bool _isOnline = true;
  DateTime? _lastOnlineTime;
  DateTime? _lastOfflineTime;
  final List<Function(bool)> _connectivityListeners = [];

  /// Initialize network manager
  Future<void> initialize() async {
    // Check initial connectivity
    _currentConnectivity = await _connectivity.checkConnectivity();
    _isOnline = _currentConnectivity != ConnectivityResult.none;
    
    if (_isOnline) {
      _lastOnlineTime = DateTime.now();
    } else {
      _lastOfflineTime = DateTime.now();
    }

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );

    print('NetworkManager: Initialized (${_isOnline ? "Online" : "Offline"})');
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _currentConnectivity = result;
    _isOnline = result != ConnectivityResult.none;

    if (_isOnline && !wasOnline) {
      // Came back online
      _lastOnlineTime = DateTime.now();
      print('NetworkManager: Connection restored');
      _notifyConnectivityListeners(true);
    } else if (!_isOnline && wasOnline) {
      // Went offline
      _lastOfflineTime = DateTime.now();
      print('NetworkManager: Connection lost');
      _notifyConnectivityListeners(false);
    }

    notifyListeners();
  }

  /// Add connectivity listener
  void addConnectivityListener(Function(bool) listener) {
    _connectivityListeners.add(listener);
  }

  /// Remove connectivity listener
  void removeConnectivityListener(Function(bool) listener) {
    _connectivityListeners.remove(listener);
  }

  /// Notify all connectivity listeners
  void _notifyConnectivityListeners(bool isOnline) {
    for (final listener in _connectivityListeners) {
      try {
        listener(isOnline);
      } catch (e) {
        if (kDebugMode) {
          print('Error in connectivity listener: $e');
        }
      }
    }
  }

  /// Check if device is online
  bool get isOnline => _isOnline;

  /// Check if device is offline
  bool get isOffline => !_isOnline;

  /// Get current connectivity type
  ConnectivityResult get currentConnectivity => _currentConnectivity;

  /// Get connection type name
  String get connectionTypeName {
    switch (_currentConnectivity) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.none:
        return 'No Connection';
      default:
        return 'Unknown';
    }
  }

  /// Get last online time
  DateTime? get lastOnlineTime => _lastOnlineTime;

  /// Get last offline time
  DateTime? get lastOfflineTime => _lastOfflineTime;

  /// Get offline duration
  Duration? get offlineDuration {
    if (_isOnline || _lastOfflineTime == null) return null;
    return DateTime.now().difference(_lastOfflineTime!);
  }

  /// Execute operation with network check
  Future<T> executeWithNetworkCheck<T>({
    required Future<T> Function() onlineOperation,
    required T Function() offlineFallback,
    bool showOfflineMessage = true,
  }) async {
    if (_isOnline) {
      try {
        return await onlineOperation();
      } catch (e) {
        if (kDebugMode) {
          print('Network operation failed: $e');
        }
        rethrow;
      }
    } else {
      if (showOfflineMessage && kDebugMode) {
        print('Device is offline, using fallback');
      }
      return offlineFallback();
    }
  }

  /// Wait for connection to be restored
  Future<bool> waitForConnection({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (_isOnline) return true;

    final completer = Completer<bool>();
    Timer? timeoutTimer;

    void listener(bool isOnline) {
      if (isOnline && !completer.isCompleted) {
        timeoutTimer?.cancel();
        completer.complete(true);
      }
    }

    addConnectivityListener(listener);

    timeoutTimer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    final result = await completer.future;
    removeConnectivityListener(listener);

    return result;
  }

  /// Get network status summary
  NetworkStatus getNetworkStatus() {
    return NetworkStatus(
      isOnline: _isOnline,
      connectivityType: _currentConnectivity,
      connectionTypeName: connectionTypeName,
      lastOnlineTime: _lastOnlineTime,
      lastOfflineTime: _lastOfflineTime,
      offlineDuration: offlineDuration,
    );
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityListeners.clear();
    super.dispose();
  }
}

/// Network status information
class NetworkStatus {
  final bool isOnline;
  final ConnectivityResult connectivityType;
  final String connectionTypeName;
  final DateTime? lastOnlineTime;
  final DateTime? lastOfflineTime;
  final Duration? offlineDuration;

  NetworkStatus({
    required this.isOnline,
    required this.connectivityType,
    required this.connectionTypeName,
    this.lastOnlineTime,
    this.lastOfflineTime,
    this.offlineDuration,
  });

  String get statusMessage {
    if (isOnline) {
      return 'Connected via $connectionTypeName';
    } else {
      if (offlineDuration != null) {
        final minutes = offlineDuration!.inMinutes;
        if (minutes < 1) {
          return 'Offline for ${offlineDuration!.inSeconds} seconds';
        } else if (minutes < 60) {
          return 'Offline for $minutes minutes';
        } else {
          return 'Offline for ${offlineDuration!.inHours} hours';
        }
      }
      return 'No internet connection';
    }
  }

  @override
  String toString() {
    return 'NetworkStatus{online: $isOnline, type: $connectionTypeName, message: $statusMessage}';
  }
}

/// Offline queue for operations that need network
class OfflineOperationQueue {
  static OfflineOperationQueue? _instance;
  
  OfflineOperationQueue._();
  
  static OfflineOperationQueue get instance {
    _instance ??= OfflineOperationQueue._();
    return _instance!;
  }

  final List<QueuedOperation> _queue = [];
  bool _isProcessing = false;

  /// Add operation to queue
  void enqueue(QueuedOperation operation) {
    _queue.add(operation);
    print('OfflineQueue: Operation queued (${_queue.length} total)');
    
    // Try to process if online
    if (NetworkManager.instance.isOnline) {
      processQueue();
    }
  }

  /// Process queued operations
  Future<void> processQueue() async {
    if (_isProcessing || _queue.isEmpty) return;
    if (!NetworkManager.instance.isOnline) {
      print('OfflineQueue: Cannot process - device is offline');
      return;
    }

    _isProcessing = true;
    print('OfflineQueue: Processing ${_queue.length} operations');

    while (_queue.isNotEmpty && NetworkManager.instance.isOnline) {
      final operation = _queue.first;
      
      try {
        await operation.execute();
        _queue.removeAt(0);
        print('OfflineQueue: Operation completed successfully');
      } catch (e) {
        print('OfflineQueue: Operation failed: $e');
        
        if (operation.retryCount < operation.maxRetries) {
          operation.retryCount++;
          print('OfflineQueue: Retrying operation (${operation.retryCount}/${operation.maxRetries})');
        } else {
          _queue.removeAt(0);
          print('OfflineQueue: Operation failed after ${operation.maxRetries} retries');
        }
        
        // Wait before next operation
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    _isProcessing = false;
    print('OfflineQueue: Processing complete (${_queue.length} remaining)');
  }

  /// Get queue size
  int get queueSize => _queue.length;

  /// Clear queue
  void clearQueue() {
    _queue.clear();
    print('OfflineQueue: Queue cleared');
  }

  /// Get queued operations
  List<QueuedOperation> get queuedOperations => List.unmodifiable(_queue);
}

/// Represents an operation that can be queued for offline execution
class QueuedOperation {
  final String id;
  final String description;
  final Future<void> Function() execute;
  final int maxRetries;
  int retryCount;
  final DateTime queuedAt;

  QueuedOperation({
    required this.id,
    required this.description,
    required this.execute,
    this.maxRetries = 3,
    this.retryCount = 0,
  }) : queuedAt = DateTime.now();

  @override
  String toString() {
    return 'QueuedOperation{id: $id, description: $description, retries: $retryCount/$maxRetries}';
  }
}
