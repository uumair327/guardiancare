import 'package:equatable/equatable.dart';

/// Resource entity representing an educational resource
class ResourceEntity extends Equatable {
  final String title;
  final String url;
  final String type; // 'pdf', 'link', 'video', etc.
  final DateTime? timestamp;

  const ResourceEntity({
    required this.title,
    required this.url,
    required this.type,
    this.timestamp,
  });

  @override
  List<Object?> get props => [title, url, type, timestamp];

  bool get isValid => title.isNotEmpty && url.isNotEmpty && type.isNotEmpty;
  bool get isPdf => type.toLowerCase() == 'pdf';
  bool get isLink => type.toLowerCase() == 'link';
  bool get isVideo => type.toLowerCase() == 'video';
}
