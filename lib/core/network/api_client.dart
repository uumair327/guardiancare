import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:guardiancare/core/util/logger.dart';

import '../config/config.dart';
import '../error/exceptions.dart';

/// Abstract API client interface following Dependency Inversion Principle.
///
/// Implementations can be swapped for testing or different backends.
abstract class ApiClient {
  /// Execute a GET request
  Future<ApiResponse> get(
    String url, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  });

  /// Execute a POST request
  Future<ApiResponse> post(
    String url, {
    Map<String, String>? headers,
    dynamic body,
  });

  /// Execute a PUT request
  Future<ApiResponse> put(
    String url, {
    Map<String, String>? headers,
    dynamic body,
  });

  /// Execute a PATCH request
  Future<ApiResponse> patch(
    String url, {
    Map<String, String>? headers,
    dynamic body,
  });

  /// Execute a DELETE request
  Future<ApiResponse> delete(
    String url, {
    Map<String, String>? headers,
  });

  /// Dispose resources
  void dispose();
}

/// HTTP API client implementation.
///
/// Features:
/// - Automatic retry with exponential backoff
/// - Request/response logging in debug mode
/// - Timeout handling
/// - Error transformation
class HttpApiClient implements ApiClient {
  HttpApiClient({
    http.Client? client,
    Duration? timeout,
  })  : _client = client ?? http.Client(),
        _timeout =
            timeout ?? const Duration(seconds: NetworkConfig.connectionTimeout);

  final http.Client _client;
  final Duration _timeout;

  /// Default headers for all requests
  Map<String, String> get _defaultHeaders => {
        NetworkConfig.headerContentType: NetworkConfig.contentTypeJson,
        NetworkConfig.headerAccept: NetworkConfig.contentTypeJson,
        NetworkConfig.headerUserAgent: 'GuardianCare/${AppConfig.appVersion}',
      };

  @override
  Future<ApiResponse> get(
    String url, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) async {
    Uri uri = Uri.parse(url);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = uri.replace(queryParameters: {
        ...uri.queryParameters,
        ...queryParameters,
      });
    }

    return _executeWithRetry(
      () => _client.get(uri, headers: {..._defaultHeaders, ...?headers}),
      method: 'GET',
      url: uri.toString(),
    );
  }

  @override
  Future<ApiResponse> post(
    String url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    return _executeWithRetry(
      () => _client.post(
        Uri.parse(url),
        headers: {..._defaultHeaders, ...?headers},
        body: body is String ? body : jsonEncode(body),
      ),
      method: 'POST',
      url: url,
    );
  }

  @override
  Future<ApiResponse> put(
    String url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    return _executeWithRetry(
      () => _client.put(
        Uri.parse(url),
        headers: {..._defaultHeaders, ...?headers},
        body: body is String ? body : jsonEncode(body),
      ),
      method: 'PUT',
      url: url,
    );
  }

  @override
  Future<ApiResponse> patch(
    String url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    return _executeWithRetry(
      () => _client.patch(
        Uri.parse(url),
        headers: {..._defaultHeaders, ...?headers},
        body: body is String ? body : jsonEncode(body),
      ),
      method: 'PATCH',
      url: url,
    );
  }

  @override
  Future<ApiResponse> delete(
    String url, {
    Map<String, String>? headers,
  }) async {
    return _executeWithRetry(
      () => _client.delete(
        Uri.parse(url),
        headers: {..._defaultHeaders, ...?headers},
      ),
      method: 'DELETE',
      url: url,
    );
  }

  /// Execute request with retry logic
  Future<ApiResponse> _executeWithRetry(
    Future<http.Response> Function() request, {
    required String method,
    required String url,
    int attempt = 0,
  }) async {
    try {
      _logRequest(method, url, attempt);

      final response = await request().timeout(_timeout);

      _logResponse(response);

      if (NetworkConfig.isSuccess(response.statusCode)) {
        return ApiResponse.success(
          statusCode: response.statusCode,
          body: response.body,
          headers: response.headers,
        );
      }

      // Check if we should retry
      if (NetworkConfig.shouldRetry(response.statusCode) &&
          attempt < NetworkConfig.maxRetries) {
        final delay = _calculateRetryDelay(attempt);
        _logRetry(attempt + 1, delay);
        await Future.delayed(delay);
        return _executeWithRetry(request,
            method: method, url: url, attempt: attempt + 1);
      }

      throw NetworkException(
        'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      if (attempt < NetworkConfig.maxRetries) {
        final delay = _calculateRetryDelay(attempt);
        _logRetry(attempt + 1, delay);
        await Future.delayed(delay);
        return _executeWithRetry(request,
            method: method, url: url, attempt: attempt + 1);
      }
      throw const NetworkException('Request timed out');
    } on SocketException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Client error: ${e.message}');
    }
  }

  /// Calculate retry delay with exponential backoff
  Duration _calculateRetryDelay(int attempt) {
    final delayMs = NetworkConfig.initialRetryDelayMs *
        (NetworkConfig.retryMultiplier * attempt).toInt().clamp(1, 100);
    return Duration(
      milliseconds: delayMs.clamp(
        NetworkConfig.initialRetryDelayMs,
        NetworkConfig.maxRetryDelayMs,
      ),
    );
  }

  void _logRequest(String method, String url, int attempt) {
    Log.d('🌐 [$method] $url${attempt > 0 ? ' (retry $attempt)' : ''}');
  }

  void _logResponse(http.Response response) {
    final status = NetworkConfig.isSuccess(response.statusCode) ? '✅' : '❌';
    Log.d('$status [${response.statusCode}] ${response.body.length} bytes');
  }

  void _logRetry(int nextAttempt, Duration delay) {
    Log.w('🔄 Retrying in ${delay.inMilliseconds}ms (attempt $nextAttempt)');
  }

  @override
  void dispose() {
    _client.close();
  }
}

/// API response wrapper.
class ApiResponse {
  const ApiResponse._({
    required this.statusCode,
    required this.body,
    required this.headers,
    required this.isSuccess,
  });

  factory ApiResponse.success({
    required int statusCode,
    required String body,
    required Map<String, String> headers,
  }) {
    return ApiResponse._(
      statusCode: statusCode,
      body: body,
      headers: headers,
      isSuccess: true,
    );
  }

  /// HTTP status code
  final int statusCode;

  /// Response body as string
  final String body;

  /// Response headers
  final Map<String, String> headers;

  /// Whether the request was successful
  final bool isSuccess;

  /// Parse body as JSON
  dynamic get json => jsonDecode(body);

  /// Parse body as JSON map
  Map<String, dynamic> get jsonMap => jsonDecode(body) as Map<String, dynamic>;

  /// Parse body as JSON list
  List<dynamic> get jsonList => jsonDecode(body) as List<dynamic>;
}
