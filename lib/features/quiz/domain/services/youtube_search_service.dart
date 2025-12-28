import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';

/// Data class representing video information
///
/// This is a domain entity that represents video data returned from
/// YouTube searches. It contains only the essential information needed
/// by the application, independent of the YouTube API response format.
///
/// Requirements: 1.3, 2.2
class VideoData extends Equatable {
  /// Unique identifier for the video on YouTube
  final String videoId;

  /// Title of the video
  final String title;

  /// URL to the video's thumbnail image
  final String thumbnailUrl;

  /// Direct URL to watch the video
  final String videoUrl;

  const VideoData({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.videoUrl,
  });

  @override
  List<Object> get props => [videoId, title, thumbnailUrl, videoUrl];
}

/// Abstract interface for YouTube search operations
///
/// This interface defines the contract for searching videos on YouTube.
/// The domain layer depends only on this abstraction, following clean
/// architecture principles where the domain layer has no knowledge of
/// implementation details such as HTTP clients or API specifics.
///
/// Implementations of this interface should handle:
/// - API communication with YouTube Data API
/// - Response parsing and conversion to [VideoData]
/// - Error handling for network and API failures
///
/// Requirements: 1.3, 2.2
abstract class YoutubeSearchService {
  /// Searches for a video on YouTube using the given search term
  ///
  /// Takes a [term] string representing the search query to execute
  /// against the YouTube API.
  ///
  /// Returns [Either<Failure, VideoData>] containing:
  /// - [Right] with [VideoData] on success
  /// - [Left] with [YoutubeApiFailure] on error
  ///
  /// The search is optimized to return a single, most relevant video
  /// matching the search term.
  Future<Either<Failure, VideoData>> searchVideo(String term);
}
