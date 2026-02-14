// ignore_for_file: deprecated_member_use
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test helper utilities for video controller tests
class TestHelper {
  TestHelper._();

  /// Sets up common test environment
  static void setupTestEnvironment() {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock platform channels that might be used by the video player
    const MethodChannel('plugins.flutter.io/video_player')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'init':
          return null;
        case 'create':
          return {'textureId': 1};
        case 'setLooping':
        case 'setVolume':
        case 'play':
        case 'pause':
        case 'seekTo':
        case 'position':
        case 'dispose':
          return null;
        default:
          return null;
      }
    });
  }

  /// Creates mock video data for testing
  static Map<String, dynamic> createMockVideoData({
    String title = 'Test Video',
    String videoUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    String thumbnailUrl = 'https://example.com/thumbnail.jpg',
    String category = 'Test Category',
    String? description,
  }) {
    return {
      'title': title,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'category': category,
      if (description != null) 'description': description,
    };
  }

  /// Creates mock category data for testing
  static Map<String, dynamic> createMockCategoryData({
    String name = 'Test Category',
    String thumbnail = 'https://example.com/category.jpg',
  }) {
    return {
      'name': name,
      'thumbnail': thumbnail,
    };
  }

  /// Creates a list of mock cyberbullying videos for testing
  static List<Map<String, dynamic>> createMockCyberbullyingVideos() {
    return [
      createMockVideoData(
        title: 'Understanding Cyberbullying',
        videoUrl: 'https://www.youtube.com/watch?v=abc123',
        category: 'Cyberbullying',
      ),
      createMockVideoData(
        title: 'Preventing Online Harassment',
        videoUrl: 'https://www.youtube.com/watch?v=def456',
        category: 'Cyberbullying',
      ),
      createMockVideoData(
        title: 'Digital Citizenship',
        videoUrl: 'https://www.youtube.com/watch?v=ghi789',
        category: 'Cyberbullying',
      ),
    ];
  }

  /// Creates a list of mock categories for testing
  static List<Map<String, dynamic>> createMockCategories() {
    return [
      createMockCategoryData(
        name: 'Cyberbullying',
        thumbnail: 'https://example.com/cyberbullying.jpg',
      ),
      createMockCategoryData(
        name: 'Sexual Abuse',
        thumbnail: 'https://example.com/sexual-abuse.jpg',
      ),
      createMockCategoryData(
        name: 'Physical Abuse',
        thumbnail: 'https://example.com/physical-abuse.jpg',
      ),
      createMockCategoryData(
        name: 'Our Work',
        thumbnail: 'https://example.com/our-work.jpg',
      ),
    ];
  }

  /// Validates that a widget tree contains expected video elements
  static void expectVideoListElements(
      WidgetTester tester, List<String> expectedTitles) {
    for (final title in expectedTitles) {
      expect(find.text(title), findsOneWidget);
    }
  }

  /// Validates that a widget tree contains expected category elements
  static void expectCategoryListElements(
      WidgetTester tester, List<String> expectedCategories) {
    for (final category in expectedCategories) {
      expect(find.text(category), findsOneWidget);
    }
  }

  /// Simulates a network error for testing error handling
  static Exception createNetworkError() {
    return Exception('Network error: Unable to connect to Firestore');
  }

  /// Simulates a timeout error for testing timeout handling
  static Exception createTimeoutError() {
    return Exception(
        'Request timed out. Please check your internet connection.');
  }
}

/// Custom matchers for video testing
class VideoTestMatchers {
  VideoTestMatchers._();

  /// Matches a valid YouTube URL
  static Matcher isValidYouTubeUrl = predicate<String>((url) {
    final youtubePattern = RegExp(
        r'youtube\.com/watch\?v=([a-zA-Z0-9_-]{11})|youtu\.be/([a-zA-Z0-9_-]{11})');
    return youtubePattern.hasMatch(url);
  }, 'is a valid YouTube URL');

  /// Matches a valid HTTP/HTTPS URL
  static Matcher isValidHttpUrl = predicate<String>((url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } on Object catch (_) {
      return false;
    }
  }, 'is a valid HTTP/HTTPS URL');

  /// Matches complete video data
  static Matcher hasCompleteVideoData = predicate<Map<String, dynamic>>((data) {
    return data.containsKey('title') &&
        data.containsKey('videoUrl') &&
        data.containsKey('thumbnailUrl') &&
        data.containsKey('category') &&
        data['title'] != null &&
        data['videoUrl'] != null &&
        data['thumbnailUrl'] != null &&
        data['category'] != null;
  }, 'has complete video data');

  /// Matches complete category data
  static Matcher hasCompleteCategoryData =
      predicate<Map<String, dynamic>>((data) {
    return data.containsKey('name') &&
        data.containsKey('thumbnail') &&
        data['name'] != null &&
        data['thumbnail'] != null;
  }, 'has complete category data');
}
