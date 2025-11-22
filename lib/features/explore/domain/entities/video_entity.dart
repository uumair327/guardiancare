import 'package:equatable/equatable.dart';

/// Video entity representing a recommended video
class VideoEntity extends Equatable {
  final String thumbnail;
  final String title;
  final String videoUrl;
  final String? category;
  final DateTime? timestamp;

  const VideoEntity({
    required this.thumbnail,
    required this.title,
    required this.videoUrl,
    this.category,
    this.timestamp,
  });

  @override
  List<Object?> get props => [thumbnail, title, videoUrl, category, timestamp];

  bool get isValid =>
      thumbnail.isNotEmpty && title.isNotEmpty && videoUrl.isNotEmpty;
}
