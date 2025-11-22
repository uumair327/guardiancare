import 'package:equatable/equatable.dart';

/// Emergency contact entity representing an emergency contact
class EmergencyContactEntity extends Equatable {
  final String name;
  final String number;
  final String category;
  final String? description;

  const EmergencyContactEntity({
    required this.name,
    required this.number,
    required this.category,
    this.description,
  });

  @override
  List<Object?> get props => [name, number, category, description];

  bool get isValid => name.isNotEmpty && number.isNotEmpty;
}
