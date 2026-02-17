import 'package:equatable/equatable.dart';

/// Domain-layer validator for parental key format.
///
/// Encapsulates business rules for key validation, keeping domain
/// logic out of the Bloc (Clean Architecture / SRP compliance).
class ParentalKeyValidator {
  const ParentalKeyValidator();

  /// Minimum length for a valid parental key.
  static const int minKeyLength = 4;

  /// Validates the format of a parental key.
  ///
  /// Returns a [ParentalKeyValidationResult] with success/failure details.
  ParentalKeyValidationResult validate(String key) {
    if (key.isEmpty) {
      return const ParentalKeyValidationResult(
        isValid: false,
        errorMessage: 'Parental key cannot be empty',
      );
    }

    if (key.length < minKeyLength) {
      return const ParentalKeyValidationResult(
        isValid: false,
        errorMessage: 'Parental key must be at least $minKeyLength characters',
      );
    }

    return const ParentalKeyValidationResult(isValid: true);
  }
}

/// Immutable result of parental key validation.
class ParentalKeyValidationResult extends Equatable {
  const ParentalKeyValidationResult({
    required this.isValid,
    this.errorMessage,
  });

  final bool isValid;
  final String? errorMessage;

  @override
  List<Object?> get props => [isValid, errorMessage];
}
