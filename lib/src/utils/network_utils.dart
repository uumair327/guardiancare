import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/utils/ui_utils.dart';

class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  NetworkException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'NetworkException: $message (Status: $statusCode)';
}

class NetworkUtils {
  // Singleton pattern
  static final NetworkUtils _instance = NetworkUtils._internal();
  factory NetworkUtils() => _instance;
  NetworkUtils._internal();

  // Check internet connectivity
  Future<bool> get isConnected async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      
      // Additional check to verify actual internet connectivity
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // Handle GET request
  Future<dynamic> get(
    String url, {
    Map<String, String>? headers,
    bool showError = true,
    BuildContext? context,
  }) async {
    return _handleRequest(
      url: url,
      method: 'GET',
      headers: headers,
      showError: showError,
      context: context,
    );
  }

  // Handle POST request
  Future<dynamic> post(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    bool showError = true,
    BuildContext? context,
  }) async {
    return _handleRequest(
      url: url,
      method: 'POST',
      headers: headers,
      body: body,
      showError: showError,
      context: context,
    );
  }

  // Handle PUT request
  Future<dynamic> put(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    bool showError = true,
    BuildContext? context,
  }) async {
    return _handleRequest(
      url: url,
      method: 'PUT',
      headers: headers,
      body: body,
      showError: showError,
      context: context,
    );
  }

  // Handle DELETE request
  Future<dynamic> delete(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    bool showError = true,
    BuildContext? context,
  }) async {
    return _handleRequest(
      url: url,
      method: 'DELETE',
      headers: headers,
      body: body,
      showError: showError,
      context: context,
    );
  }

  // Generic request handler
  Future<dynamic> _handleRequest({
    required String url,
    required String method,
    Map<String, String>? headers,
    dynamic body,
    bool showError = true,
    BuildContext? context,
  }) async {
    // Check for internet connectivity
    if (!await isConnected) {
      final error = NetworkException(message: 'No internet connection');
      _handleError(error, showError, context);
      throw error;
    }

    // Show loading indicator if context is provided
    if (context != null) {
      UIUtils.showLoadingDialog(context);
    }

    try {
      final httpClient = HttpClient();
      final request = await httpClient.openUrl(method, Uri.parse(url));
      
      // Set headers
      request.headers.set('Content-Type', 'application/json');
      if (headers != null) {
        headers.forEach((key, value) {
          request.headers.set(key, value);
        });
      }

      // Add request body for POST/PUT requests
      if (method != 'GET' && body != null) {
        request.add(utf8.encode(json.encode(body)));
      }

      // Get response
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      // Close loading dialog
      if (context != null && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Handle response
      final statusCode = response.statusCode;
      dynamic jsonResponse;
      
      try {
        jsonResponse = responseBody.isNotEmpty ? json.decode(responseBody) : null;
      } catch (e) {
        // If response is not JSON, return as string
        return responseBody;
      }

      // Check for error status codes
      if (statusCode >= 400) {
        final error = NetworkException(
          message: jsonResponse?['message'] ?? 'Request failed with status: $statusCode',
          statusCode: statusCode,
          data: jsonResponse,
        );
        _handleError(error, showError, context);
        throw error;
      }

      return jsonResponse;
    } on SocketException {
      final error = NetworkException(message: 'No internet connection');
      _handleError(error, showError, context);
      rethrow;
    } on HttpException catch (e) {
      final error = NetworkException(message: 'HTTP error: ${e.message}');
      _handleError(error, showError, context);
      rethrow;
    } on FormatException {
      final error = NetworkException(message: 'Invalid response format');
      _handleError(error, showError, context);
      rethrow;
    } catch (e) {
      final error = NetworkException(message: 'An unexpected error occurred: $e');
      _handleError(error, showError, context);
      rethrow;
    } finally {
      // Ensure loading dialog is closed
      if (context != null && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    }
  }

  // Handle errors
  void _handleError(
    NetworkException error,
    bool showError,
    BuildContext? context,
  ) {
    if (showError && context != null) {
      UIUtils.showSnackBar(
        context: context,
        message: error.message,
        backgroundColor: tErrorColor,
      );
    }
  }

  // Upload file
  Future<Map<String, dynamic>> uploadFile({
    required String url,
    required String filePath,
    String method = 'POST',
    Map<String, String>? headers,
    Map<String, String>? fields,
    bool showError = true,
    BuildContext? context,
  }) async {
    try {
      final request = await HttpClient().postUrl(Uri.parse(url));
      
      // Set headers
      request.headers.set('Content-Type', 'multipart/form-data');
      if (headers != null) {
        headers.forEach((key, value) {
          request.headers.set(key, value);
        });
      }

      // Create multipart request
      final boundary = '----WebKitFormBoundary${DateTime.now().millisecondsSinceEpoch}';
      request.headers.set('Content-Type', 'multipart/form-data; boundary=$boundary');
      
      // Add form fields
      final buffer = StringBuffer();
      if (fields != null) {
        fields.forEach((key, value) {
          buffer.write('--$boundary\r\n');
          buffer.write('Content-Disposition: form-data; name="$key"\r\n\r\n');
          buffer.write('$value\r\n');
        });
      }
      
      // Add file
      final file = File(filePath);
      final fileBytes = await file.readAsBytes();
      final fileName = file.path.split('/').last;
      
      buffer.write('--$boundary\r\n');
      buffer.write('Content-Disposition: form-data; name="file"; filename="$fileName"\r\n');
      buffer.write('Content-Type: application/octet-stream\r\n\r\n');
      
      final headerBytes = utf8.encode(buffer.toString());
      final footerBytes = utf8.encode('\r\n--$boundary--\r\n');
      
      final contentLength = headerBytes.length + fileBytes.length + footerBytes.length;
      request.contentLength = contentLength;
      
      // Write to request
      request.add(headerBytes);
      request.add(fileBytes);
      request.add(footerBytes);
      
      // Get response
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      if (response.statusCode >= 400) {
        throw NetworkException(
          message: 'Upload failed with status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
      
      return json.decode(responseBody);
    } catch (e) {
      _handleError(
        e is NetworkException ? e : NetworkException(message: e.toString()),
        showError,
        context,
      );
      rethrow;
    }
  }
}
