import 'package:flutter_test/flutter_test.dart';

// Helper functions for video validation testing
class VideoValidationHelper {
  static bool isValidVideoUrl(String url) {
    if (url.isEmpty) return false;
    
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  static bool isValidYouTubeUrl(String url) {
    if (url.isEmpty) return false;
    
    // Simple YouTube URL validation patterns
    final youtubePatterns = [
      RegExp(r'youtube\.com/watch\?v=([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtu\.be/([a-zA-Z0-9_-]{11})'),
      RegExp(r'm\.youtube\.com/watch\?v=([a-zA-Z0-9_-]{11})'),
    ];
    
    return youtubePatterns.any((pattern) => pattern.hasMatch(url));
  }

  static String? extractYouTubeVideoId(String url) {
    if (url.isEmpty) return null;
    
    final patterns = [
      RegExp(r'youtube\.com/watch\?v=([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtu\.be/([a-zA-Z0-9_-]{11})'),
      RegExp(r'm\.youtube\.com/watch\?v=([a-zA-Z0-9_-]{11})'),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null) {
        return match.group(1);
      }
    }
    
    return null;
  }

  static bool isValidVideoData(Map<String, dynamic> videoData) {
    final title = videoData['title'] as String?;
    final videoUrl = videoData['videoUrl'] as String?;
    final thumbnailUrl = videoData['thumbnailUrl'] as String?;
    final category = videoData['category'] as String?;
    
    return title != null && title.isNotEmpty &&
           videoUrl != null && videoUrl.isNotEmpty &&
           thumbnailUrl != null && thumbnailUrl.isNotEmpty &&
           category != null && category.isNotEmpty &&
           isValidVideoUrl(videoUrl) &&
           isValidVideoUrl(thumbnailUrl);
  }

  static bool isValidCategoryData(Map<String, dynamic> categoryData) {
    final name = categoryData['name'] as String?;
    final thumbnail = categoryData['thumbnail'] as String?;
    
    return name != null && name.isNotEmpty &&
           thumbnail != null && thumbnail.isNotEmpty &&
           isValidVideoUrl(thumbnail);
  }
}

void main() {
  group('Video URL Validation Tests', () {
    test('should validate basic HTTP/HTTPS URLs', () {
      expect(VideoValidationHelper.isValidVideoUrl('https://example.com'), isTrue);
      expect(VideoValidationHelper.isValidVideoUrl('http://example.com'), isTrue);
      expect(VideoValidationHelper.isValidVideoUrl('ftp://example.com'), isFalse);
      expect(VideoValidationHelper.isValidVideoUrl(''), isFalse);
      expect(VideoValidationHelper.isValidVideoUrl('not-a-url'), isFalse);
    });

    test('should validate YouTube URLs correctly', () {
      // Valid YouTube URLs
      expect(VideoValidationHelper.isValidYouTubeUrl('https://www.youtube.com/watch?v=dQw4w9WgXcQ'), isTrue);
      expect(VideoValidationHelper.isValidYouTubeUrl('https://youtu.be/dQw4w9WgXcQ'), isTrue);
      expect(VideoValidationHelper.isValidYouTubeUrl('https://m.youtube.com/watch?v=dQw4w9WgXcQ'), isTrue);
      
      // Invalid YouTube URLs
      expect(VideoValidationHelper.isValidYouTubeUrl('https://vimeo.com/123456'), isFalse);
      expect(VideoValidationHelper.isValidYouTubeUrl('https://example.com'), isFalse);
      expect(VideoValidationHelper.isValidYouTubeUrl(''), isFalse);
      expect(VideoValidationHelper.isValidYouTubeUrl('not-a-url'), isFalse);
    });

    test('should extract YouTube video IDs correctly', () {
      expect(VideoValidationHelper.extractYouTubeVideoId('https://www.youtube.com/watch?v=dQw4w9WgXcQ'), equals('dQw4w9WgXcQ'));
      expect(VideoValidationHelper.extractYouTubeVideoId('https://youtu.be/dQw4w9WgXcQ'), equals('dQw4w9WgXcQ'));
      expect(VideoValidationHelper.extractYouTubeVideoId('https://m.youtube.com/watch?v=dQw4w9WgXcQ'), equals('dQw4w9WgXcQ'));
      expect(VideoValidationHelper.extractYouTubeVideoId('https://example.com'), isNull);
      expect(VideoValidationHelper.extractYouTubeVideoId(''), isNull);
    });

    test('should handle YouTube URLs with additional parameters', () {
      final urlWithParams = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=1m30s&list=PLrAXtmRdnEQy';
      expect(VideoValidationHelper.isValidYouTubeUrl(urlWithParams), isTrue);
      expect(VideoValidationHelper.extractYouTubeVideoId(urlWithParams), equals('dQw4w9WgXcQ'));
    });
  });

  group('Video Data Validation Tests', () {
    test('should validate complete video data', () {
      final validVideoData = {
        'title': 'Test Video',
        'videoUrl': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'thumbnailUrl': 'https://example.com/thumbnail.jpg',
        'category': 'Cyberbullying',
      };
      
      expect(VideoValidationHelper.isValidVideoData(validVideoData), isTrue);
    });

    test('should reject incomplete video data', () {
      final incompleteVideoData = {
        'title': 'Test Video',
        'videoUrl': '', // Empty URL
        'thumbnailUrl': 'https://example.com/thumbnail.jpg',
        'category': 'Cyberbullying',
      };
      
      expect(VideoValidationHelper.isValidVideoData(incompleteVideoData), isFalse);
    });

    test('should reject video data with missing fields', () {
      final missingFieldsData = {
        'title': 'Test Video',
        // Missing videoUrl
        'thumbnailUrl': 'https://example.com/thumbnail.jpg',
        'category': 'Cyberbullying',
      };
      
      expect(VideoValidationHelper.isValidVideoData(missingFieldsData), isFalse);
    });

    test('should reject video data with invalid URLs', () {
      final invalidUrlData = {
        'title': 'Test Video',
        'videoUrl': 'not-a-valid-url',
        'thumbnailUrl': 'https://example.com/thumbnail.jpg',
        'category': 'Cyberbullying',
      };
      
      expect(VideoValidationHelper.isValidVideoData(invalidUrlData), isFalse);
    });
  });

  group('Category Data Validation Tests', () {
    test('should validate complete category data', () {
      final validCategoryData = {
        'name': 'Cyberbullying',
        'thumbnail': 'https://example.com/cyberbullying.jpg',
      };
      
      expect(VideoValidationHelper.isValidCategoryData(validCategoryData), isTrue);
    });

    test('should reject incomplete category data', () {
      final incompleteCategoryData = {
        'name': '', // Empty name
        'thumbnail': 'https://example.com/cyberbullying.jpg',
      };
      
      expect(VideoValidationHelper.isValidCategoryData(incompleteCategoryData), isFalse);
    });

    test('should reject category data with missing fields', () {
      final missingFieldsData = {
        'name': 'Cyberbullying',
        // Missing thumbnail
      };
      
      expect(VideoValidationHelper.isValidCategoryData(missingFieldsData), isFalse);
    });

    test('should reject category data with invalid thumbnail URL', () {
      final invalidThumbnailData = {
        'name': 'Cyberbullying',
        'thumbnail': 'not-a-valid-url',
      };
      
      expect(VideoValidationHelper.isValidCategoryData(invalidThumbnailData), isFalse);
    });
  });

  group('Edge Case Tests', () {
    test('should handle null values gracefully', () {
      final nullData = {
        'title': null,
        'videoUrl': null,
        'thumbnailUrl': null,
        'category': null,
      };
      
      expect(VideoValidationHelper.isValidVideoData(nullData), isFalse);
    });

    test('should handle empty map', () {
      expect(VideoValidationHelper.isValidVideoData({}), isFalse);
      expect(VideoValidationHelper.isValidCategoryData({}), isFalse);
    });

    test('should handle very long URLs', () {
      final longUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ' + '&param=' * 100 + 'value';
      expect(VideoValidationHelper.isValidVideoUrl(longUrl), isTrue);
      expect(VideoValidationHelper.isValidYouTubeUrl(longUrl), isTrue);
    });

    test('should handle special characters in URLs', () {
      final specialCharUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=1m30s&list=PLrAXtmRdnEQy';
      expect(VideoValidationHelper.isValidVideoUrl(specialCharUrl), isTrue);
      expect(VideoValidationHelper.isValidYouTubeUrl(specialCharUrl), isTrue);
    });
  });
}