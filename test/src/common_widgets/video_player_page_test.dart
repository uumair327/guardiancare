import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardiancare/src/common_widgets/video_player_page.dart';

void main() {
  group('VideoPlayerPage Tests', () {
    testWidgets('should display error for invalid YouTube URL', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: VideoPlayerPage(videoUrl: 'invalid-url'),
        ),
      );

      await tester.pumpAndSettle();

      // Should show error message for invalid URL
      expect(find.text('Invalid YouTube URL'), findsOneWidget);
    });

    testWidgets('should display error for empty URL', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: VideoPlayerPage(videoUrl: ''),
        ),
      );

      await tester.pumpAndSettle();

      // Should show error message for empty URL
      expect(find.text('Invalid YouTube URL'), findsOneWidget);
    });

    testWidgets('should have proper app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: VideoPlayerPage(videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
        ),
      );

      await tester.pumpAndSettle();

      // Should have app bar with title
      expect(find.text('Video Player'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should initialize with valid YouTube URL', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: VideoPlayerPage(videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
        ),
      );

      await tester.pumpAndSettle();

      // Should not show error message for valid URL
      expect(find.text('Invalid YouTube URL'), findsNothing);
      expect(find.byType(VideoPlayerPage), findsOneWidget);
    });

    testWidgets('should handle different YouTube URL formats', (WidgetTester tester) async {
      final validUrls = [
        'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'https://youtu.be/dQw4w9WgXcQ',
        'https://m.youtube.com/watch?v=dQw4w9WgXcQ',
      ];

      for (final url in validUrls) {
        await tester.pumpWidget(
          MaterialApp(
            home: VideoPlayerPage(videoUrl: url),
          ),
        );

        await tester.pumpAndSettle();

        // Should not show error for valid YouTube URLs
        expect(find.text('Invalid YouTube URL'), findsNothing);
        
        // Clean up for next iteration
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/navigation',
          null,
          (data) {},
        );
      }
    });

    testWidgets('should reject non-YouTube URLs', (WidgetTester tester) async {
      final invalidUrls = [
        'https://vimeo.com/123456',
        'https://example.com/video.mp4',
        'not-a-url',
        'https://youtube.com', // Missing video ID
      ];

      for (final url in invalidUrls) {
        await tester.pumpWidget(
          MaterialApp(
            home: VideoPlayerPage(videoUrl: url),
          ),
        );

        await tester.pumpAndSettle();

        // Should show error for invalid URLs
        expect(find.text('Invalid YouTube URL'), findsOneWidget);
        
        // Clean up for next iteration
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/navigation',
          null,
          (data) {},
        );
      }
    });
  });

  group('VideoPlayerPage Edge Cases', () {
    testWidgets('should handle null URL gracefully', (WidgetTester tester) async {
      // This test ensures the widget doesn't crash with null input
      // In practice, the constructor requires non-null String
      await tester.pumpWidget(
        MaterialApp(
          home: VideoPlayerPage(videoUrl: ''),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(VideoPlayerPage), findsOneWidget);
      expect(find.text('Invalid YouTube URL'), findsOneWidget);
    });

    testWidgets('should handle very long URLs', (WidgetTester tester) async {
      final longUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ' + '&' + 'param=' * 100 + 'value';
      
      await tester.pumpWidget(
        MaterialApp(
          home: VideoPlayerPage(videoUrl: longUrl),
        ),
      );

      await tester.pumpAndSettle();

      // Should still extract video ID correctly
      expect(find.text('Invalid YouTube URL'), findsNothing);
    });

    testWidgets('should handle URLs with special characters', (WidgetTester tester) async {
      final urlWithSpecialChars = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=1m30s&list=PLrAXtmRdnEQy';
      
      await tester.pumpWidget(
        MaterialApp(
          home: VideoPlayerPage(videoUrl: urlWithSpecialChars),
        ),
      );

      await tester.pumpAndSettle();

      // Should handle URLs with additional parameters
      expect(find.text('Invalid YouTube URL'), findsNothing);
    });
  });
}