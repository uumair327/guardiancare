/// External API endpoint configuration.
///
/// This class follows the Open/Closed Principle (OCP) - open for extension
/// but closed for modification. New API services can be added without
/// modifying existing code.
///
/// ## Purpose
/// - Centralizes all external API endpoint definitions
/// - Provides URL builders for consistent endpoint construction
/// - Enables easy API versioning and environment switching
///
/// ## Usage
/// ```dart
/// final searchUrl = ApiEndpoints.youtube.searchVideos(
///   query: 'child safety',
///   maxResults: 10,
/// );
/// ```
abstract final class ApiEndpoints {
  ApiEndpoints._();

  /// YouTube API endpoints
  static const youtube = _YouTubeEndpoints();

  /// Gemini AI API endpoints
  static const gemini = _GeminiEndpoints();

  /// Common external resource URLs
  static const external = _ExternalUrls();
}

/// YouTube Data API v3 endpoints.
class _YouTubeEndpoints {
  const _YouTubeEndpoints();

  /// Base URL for YouTube Data API
  String get baseUrl => 'https://www.googleapis.com/youtube/v3';

  /// Search endpoint
  String get search => '$baseUrl/search';

  /// Videos endpoint
  String get videos => '$baseUrl/videos';

  /// Channels endpoint
  String get channels => '$baseUrl/channels';

  /// Playlist items endpoint
  String get playlistItems => '$baseUrl/playlistItems';

  /// Build search URL with parameters
  Uri searchVideos({
    required String query,
    required String apiKey,
    int maxResults = 10,
    String? pageToken,
  }) {
    return Uri.parse(search).replace(
      queryParameters: {
        'part': 'snippet',
        'type': 'video',
        'q': query,
        'maxResults': maxResults.toString(),
        'key': apiKey,
        if (pageToken != null) 'pageToken': pageToken,
      },
    );
  }

  /// Build video details URL
  Uri getVideoDetails({
    required String videoId,
    required String apiKey,
  }) {
    return Uri.parse(videos).replace(
      queryParameters: {
        'part': 'snippet,contentDetails,statistics',
        'id': videoId,
        'key': apiKey,
      },
    );
  }

  /// Get YouTube video embed URL
  String embedUrl(String videoId) => 'https://www.youtube.com/embed/$videoId';

  /// Get YouTube video thumbnail URL
  String thumbnailUrl(String videoId,
      {ThumbnailQuality quality = ThumbnailQuality.high}) {
    final qualityStr = switch (quality) {
      ThumbnailQuality.default_ => 'default',
      ThumbnailQuality.medium => 'mqdefault',
      ThumbnailQuality.high => 'hqdefault',
      ThumbnailQuality.standard => 'sddefault',
      ThumbnailQuality.maxres => 'maxresdefault',
    };
    return 'https://img.youtube.com/vi/$videoId/$qualityStr.jpg';
  }

  /// Get YouTube video watch URL
  String watchUrl(String videoId) => 'https://www.youtube.com/watch?v=$videoId';
}

/// YouTube thumbnail quality options.
enum ThumbnailQuality {
  default_,
  medium,
  high,
  standard,
  maxres,
}

/// Gemini AI API endpoints.
class _GeminiEndpoints {
  const _GeminiEndpoints();

  /// Base URL for Gemini API
  String get baseUrl => 'https://generativelanguage.googleapis.com';

  /// API version
  String get version => 'v1beta';

  /// Generate content endpoint
  String generateContent(String model) =>
      '$baseUrl/$version/models/$model:generateContent';

  /// Stream generate content endpoint
  String streamGenerateContent(String model) =>
      '$baseUrl/$version/models/$model:streamGenerateContent';

  /// List models endpoint
  String get listModels => '$baseUrl/$version/models';

  /// Default model for general use
  String get defaultModel => 'gemini-pro';

  /// Vision model for image analysis
  String get visionModel => 'gemini-pro-vision';
}

/// External resource URLs.
class _ExternalUrls {
  const _ExternalUrls();

  /// Privacy policy URL
  String get privacyPolicy => 'https://guardiancare.app/privacy';

  /// Terms of service URL
  String get termsOfService => 'https://guardiancare.app/terms';

  /// Support email
  String get supportEmail => 'support@guardiancare.app';

  /// App store URL (iOS)
  String get appStoreUrl => 'https://apps.apple.com/app/guardiancare';

  /// Play Store URL (Android)
  String get playStoreUrl =>
      'https://play.google.com/store/apps/details?id=app.guardiancare.guardiancare';

  /// Help center URL
  String get helpCenter => 'https://guardiancare.app/help';

  /// Feedback form URL
  String get feedbackForm => 'https://guardiancare.app/feedback';

  // ==================== External Safety Resources ====================
  /// National Center for Missing & Exploited Children
  String get ncmec => 'https://www.missingkids.org/';

  /// Family Online Safety Institute
  String get fosi => 'https://www.fosi.org/';

  /// Common Sense Media
  String get commonSenseMedia => 'https://www.commonsensemedia.org/';

  /// Cyberbullying Research Center
  String get cyberbullyingResearch => 'https://cyberbullying.org/';
}
