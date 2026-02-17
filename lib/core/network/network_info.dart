import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

/// Interface for checking network connectivity
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Implementation of NetworkInfo that works on all platforms (web + native).
///
/// On web: Uses an HTTP HEAD request since dart:io is unavailable.
/// On native: Also uses HTTP for consistency and simplicity.
///
/// Previously used `dart:io` `InternetAddress.lookup()` which is not
/// available on web and caused login to crash on Chrome.
class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    try {
      if (kIsWeb) {
        // On web, we can generally assume connectivity exists.
        // The actual Firebase/Supabase calls will fail with proper errors
        // if there's truly no network.
        // Doing an HTTP check on web can fail due to CORS.
        return true;
      }

      // On native platforms, do a lightweight connectivity check
      final response = await http
          .head(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } on Object catch (_) {
      return false;
    }
  }
}
