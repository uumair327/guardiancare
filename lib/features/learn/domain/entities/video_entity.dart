import 'package:equatable/equatable.dart';

/// Video entity representing a learning video
class VideoEntity extends Equatable {
  final String id;
  final String title;
  final String videoUrl;
  final String thumbnailUrl;
  final String category;
  final String? description;

  const VideoEntity({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.category,
    this.description,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        videoUrl,
        thumbnailUrl,
        category,
        description,
      ];

  bool get isValid =>
      title.isNotEmpty &&
      videoUrl.isNotEmpty &&
      thumbnailUrl.isNotEmpty &&
      category.isNotEmpty;
}
