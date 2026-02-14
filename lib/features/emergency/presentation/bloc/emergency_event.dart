import 'package:equatable/equatable.dart';

/// Base class for emergency events
abstract class EmergencyEvent extends Equatable {
  const EmergencyEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all emergency contacts
class LoadEmergencyContacts extends EmergencyEvent {}

/// Event to load contacts by category
class LoadContactsByCategory extends EmergencyEvent {

  const LoadContactsByCategory(this.category);
  final String category;

  @override
  List<Object?> get props => [category];
}

/// Event to make an emergency call
class MakeCallRequested extends EmergencyEvent {

  const MakeCallRequested(this.phoneNumber);
  final String phoneNumber;

  @override
  List<Object?> get props => [phoneNumber];
}
