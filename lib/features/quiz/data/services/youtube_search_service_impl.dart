import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/constants/constants.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/util/logger.dart';
import 'package:guardiancare/features/quiz/domain/services/youtube_search_service.dart';
import 'package:http/http.dart' as http;

/// Implementation of [YoutubeSearchService] using YouTube Data API v3
///
/// This class provides the concrete implementation for searching
/// YouTube videos based on search terms. It handles API communication,
/// response parsing, and error handling.
///
/// Requirements: 1.2, 5.1
class YoutubeSearchServiceImpl implements YoutubeSearchService {
  /// Creates a [YoutubeSearchServiceImpl]
  ///
  /// [httpClient] - HTTP client for making API requests (optional, defaults to new client)
  /// [apiKey] - YouTube API key (optional, defaults to kYoutubeApiKey)
  YoutubeSearchServiceImpl({
    http.Client? httpClient,
    String? apiKey,
  })  : _httpClient = httpClient ?? http.Client(),
        _apiKey = apiKey ?? kYoutubeApiKey;
  final http.Client _httpClient;
  final String _apiKey;

  @override
  Future<Either<Failure, VideoData>> searchVideo(String term) async {
    if (term.isEmpty) {
      return const Left(YoutubeApiFailure(ErrorStrings.youtubeSearchTermEmpty));
    }

    // Skip invalid terms that start with dash
    if (term.startsWith('-')) {
      return const Left(
          YoutubeApiFailure(ErrorStrings.youtubeInvalidTermFormat));
    }

    try {
      final formattedTerm = term.trim();
      Log.d('🔍 YouTube API: Searching for "$formattedTerm"');

      final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search'
        '?part=snippet'
        '&q=${Uri.encodeComponent(formattedTerm)}'
        '&maxResults=1'
        '&type=video'
        '&key=$_apiKey',
      );

      final response = await _httpClient.get(url);

      if (response.statusCode != 200) {
        Log.e('❌ YouTube API error: Status ${response.statusCode}');
        Log.e('   Response: ${response.body}');
        return Left(YoutubeApiFailure(
          '${ErrorStrings.youtubeApiRequestFailed} ${response.statusCode}',
          code: response.statusCode.toString(),
        ));
      }

      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      final items = jsonData['items'] as List<dynamic>?;

      if (items == null || items.isEmpty) {
        Log.w('⚠️ YouTube API: No videos found for "$formattedTerm"');
        return Left(YoutubeApiFailure(
            ErrorStrings.withDetails(ErrorStrings.youtubeNoVideosFound, term)));
      }

      final videoData = _parseVideoData(items.first as Map<String, dynamic>);

      Log.d('✅ YouTube API: Found video "${videoData.title}"');
      return Right(videoData);
    } on Object catch (e) {
      Log.e('❌ YouTube API exception: $e');
      return Left(YoutubeApiFailure(ErrorStrings.withDetails(
          ErrorStrings.youtubeApiError, e.toString())));
    }
  }

  /// Parses YouTube API response item into [VideoData]
  VideoData _parseVideoData(Map<String, dynamic> item) {
    final videoId = item['id']['videoId'] as String;
    final snippet = item['snippet'] as Map<String, dynamic>;
    final title = snippet['title'] as String;
    final thumbnails = snippet['thumbnails'] as Map<String, dynamic>;
    final highThumbnail = thumbnails['high'] as Map<String, dynamic>;
    final thumbnailUrl = highThumbnail['url'] as String;

    return VideoData(
      videoId: videoId,
      title: title,
      thumbnailUrl: thumbnailUrl,
      videoUrl: 'https://youtu.be/$videoId',
    );
  }
}
