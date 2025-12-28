import 'package:equatable/equatable.dart';

/// Entity representing a video recommendation for quiz results
///
/// This is a domain entity that represents recommendation data.
/// It contains only the essential information needed by the application,
/// independent of any persistence mechanism.
///
/// Requirements: 4.3
class QuizRecommendation extends Equatable {
  /// Unique identifier for the recommendation (optional, assigned by persistence layer)
  final String? id;

  /// Title of the recommended video
  final String title;

  /// URL to the video
  final String videoUrl;

  /// Category the recommendation belongs to
  final String category;

  /// URL to the video's thumbnail image
  final String thumbnailUrl;

  /// Timestamp when the recommendation was created
  final DateTime? timestamp;

  /// User ID this recommendation belongs to
  final String userId;

  const QuizRecommendation({
    this.id,
    required this.title,
    required this.videoUrl,
    required this.category,
    required this.thumbnailUrl,
    this.timestamp,
    required this.userId,
  });

  @override
  List<Object?> get props => [id, title, videoUrl, category, thumbnailUrl, timestamp, userId];
}
