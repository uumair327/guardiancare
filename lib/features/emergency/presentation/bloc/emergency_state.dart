import 'package:equatable/equatable.dart';
import 'package:guardiancare/features/emergency/domain/entities/emergency_contact_entity.dart';

/// Base class for emergency states
abstract class EmergencyState extends Equatable {
  const EmergencyState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class EmergencyInitial extends EmergencyState {}

/// Loading state
class EmergencyLoading extends EmergencyState {}

/// Emergency contacts loaded successfully
class EmergencyContactsLoaded extends EmergencyState {
  final List<EmergencyContactEntity> contacts;

  const EmergencyContactsLoaded(this.contacts);

  @override
  List<Object?> get props => [contacts];

  /// Get contacts by category
  List<EmergencyContactEntity> getContactsByCategory(String category) {
    return contacts
        .where((contact) =>
            contact.category.toLowerCase() == category.toLowerCase())
        .toList();
  }
}

/// Call in progress state
class EmergencyCallInProgress extends EmergencyState {}

/// Call completed state
class EmergencyCallCompleted extends EmergencyState {}

/// Error state
class EmergencyError extends EmergencyState {
  final String message;

  const EmergencyError(this.message);

  @override
  List<Object?> get props => [message];
}
