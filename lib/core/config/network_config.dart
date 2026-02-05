/// Network configuration constants.
///
/// Follows the Single Responsibility Principle (SRP) by handling only
/// network-related configuration.
///
/// ## Usage
/// ```dart
/// final client = http.Client();
/// client.timeout = Duration(seconds: NetworkConfig.connectionTimeout);
/// ```
abstract final class NetworkConfig {
  NetworkConfig._();

  // ==================== Timeouts ====================
  /// Connection timeout in seconds
  static const int connectionTimeout = 30;

  /// Receive timeout in seconds
  static const int receiveTimeout = 30;

  /// Send timeout in seconds
  static const int sendTimeout = 30;

  /// Stream timeout in seconds
  static const int streamTimeout = 60;

  // ==================== Retry Configuration ====================
  /// Maximum retry attempts
  static const int maxRetries = 3;

  /// Initial retry delay in milliseconds
  static const int initialRetryDelayMs = 1000;

  /// Maximum retry delay in milliseconds
  static const int maxRetryDelayMs = 10000;

  /// Retry delay multiplier for exponential backoff
  static const double retryMultiplier = 2.0;

  /// HTTP status codes that should trigger a retry
  static const List<int> retryableStatusCodes = [408, 429, 500, 502, 503, 504];

  // ==================== HTTP Headers ====================
  /// Content-Type header name
  static const String headerContentType = 'Content-Type';

  /// Accept header name
  static const String headerAccept = 'Accept';

  /// Authorization header name
  static const String headerAuthorization = 'Authorization';

  /// User-Agent header name
  static const String headerUserAgent = 'User-Agent';

  /// API Key header name
  static const String headerApiKey = 'X-API-Key';

  // ==================== Content Types ====================
  /// JSON content type
  static const String contentTypeJson = 'application/json; charset=utf-8';

  /// Form URL encoded content type
  static const String contentTypeFormUrlEncoded =
      'application/x-www-form-urlencoded';

  /// Multipart form data content type
  static const String contentTypeMultipart = 'multipart/form-data';

  // ==================== Authorization ====================
  /// Bearer token prefix
  static const String bearerPrefix = 'Bearer ';

  /// Basic auth prefix
  static const String basicPrefix = 'Basic ';

  // ==================== HTTP Methods ====================
  /// GET method
  static const String methodGet = 'GET';

  /// POST method
  static const String methodPost = 'POST';

  /// PUT method
  static const String methodPut = 'PUT';

  /// PATCH method
  static const String methodPatch = 'PATCH';

  /// DELETE method
  static const String methodDelete = 'DELETE';

  // ==================== Status Code Ranges ====================
  /// Success status code range start
  static const int successRangeStart = 200;

  /// Success status code range end
  static const int successRangeEnd = 299;

  /// Client error status code range start
  static const int clientErrorRangeStart = 400;

  /// Client error status code range end
  static const int clientErrorRangeEnd = 499;

  /// Server error status code range start
  static const int serverErrorRangeStart = 500;

  /// Server error status code range end
  static const int serverErrorRangeEnd = 599;

  /// Check if status code is successful
  static bool isSuccess(int statusCode) =>
      statusCode >= successRangeStart && statusCode <= successRangeEnd;

  /// Check if status code is client error
  static bool isClientError(int statusCode) =>
      statusCode >= clientErrorRangeStart && statusCode <= clientErrorRangeEnd;

  /// Check if status code is server error
  static bool isServerError(int statusCode) =>
      statusCode >= serverErrorRangeStart && statusCode <= serverErrorRangeEnd;

  /// Check if request should be retried based on status code
  static bool shouldRetry(int statusCode) =>
      retryableStatusCodes.contains(statusCode);
}

/// Common HTTP status codes.
abstract final class HttpStatusCodes {
  HttpStatusCodes._();

  // ==================== Success ====================
  static const int ok = 200;
  static const int created = 201;
  static const int accepted = 202;
  static const int noContent = 204;

  // ==================== Redirection ====================
  static const int movedPermanently = 301;
  static const int found = 302;
  static const int notModified = 304;

  // ==================== Client Errors ====================
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int methodNotAllowed = 405;
  static const int conflict = 409;
  static const int gone = 410;
  static const int unprocessableEntity = 422;
  static const int tooManyRequests = 429;

  // ==================== Server Errors ====================
  static const int internalServerError = 500;
  static const int badGateway = 502;
  static const int serviceUnavailable = 503;
  static const int gatewayTimeout = 504;
}
