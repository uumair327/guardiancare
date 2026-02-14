import 'package:equatable/equatable.dart';

class Resource extends Equatable {

  const Resource({
    required this.id,
    required this.title,
    this.description,
    this.url,
    this.type,
    this.category,
    this.timestamp,
  });
  final String id;
  final String title;
  final String? description;
  final String? url;
  final String? type;
  final String? category;
  final DateTime? timestamp;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        url,
        type,
        category,
        timestamp,
      ];
}
