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
    this.content,
  });
  final String id;
  final String title;
  final String? description;
  final String? url;
  final String? type;
  final String? category;
  final DateTime? timestamp;
  final Map<String, dynamic>? content;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        url,
        type,
        category,
        timestamp,
        content,
      ];
}
