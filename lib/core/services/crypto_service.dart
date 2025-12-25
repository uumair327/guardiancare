import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Abstract interface for cryptographic operations
/// Handles cryptographic operations exclusively (hashString, compareHash)
/// Requirements: 9.3
abstract class CryptoService {
  /// Hash a string using SHA-256
  String hashString(String input);

  /// Compare a plain text input against a stored hash
  bool compareHash(String input, String hash);
}

/// Implementation of CryptoService using SHA-256
class CryptoServiceImpl implements CryptoService {
  const CryptoServiceImpl();

  @override
  String hashString(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  @override
  bool compareHash(String input, String hash) {
    final inputHash = hashString(input);
    return inputHash == hash;
  }
}
