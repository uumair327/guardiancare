/// Interface for checking network connectivity
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Implementation of NetworkInfo
/// You can use connectivity_plus package for actual implementation
class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // TODO: Implement using connectivity_plus package
    // For now, assume always connected
    return true;
  }
}
