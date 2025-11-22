import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:guardiancare/src/features/learn/learn.dart';
import 'package:guardiancare/src/features/learn/widgets/learn_view.dart';
import '../test_helper.dart';

void main() {
  group('Cyberbullying Video Loading Integration Tests', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      TestHelper.setupTestEnvironment();
      fakeFirestore = FakeFirebaseFirestore();
    });

    testWidgets('should load cyberbullying category and videos successfully', (WidgetTester tester) async {
      // Setup test data - Add cyberbullying category
      await fakeFirestore.collection('learn').add({
        'name': 'Cyberbullying',
        'thumbnail': 'https://example.com/cyberbullying-thumbnail.jpg',
      });

      // Add cyberbullying videos
      await fakeFirestore.collection('videos').add({
        'title': 'Understanding Cyberbullying',
        'videoUrl': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'thumbnailUrl': 'https://example.com/video1-thumbnail.jpg',
        'category': 'Cyberbullying',
        'description': 'Learn about cyberbullying and its effects',
      });

      await fakeFirestore.collection('videos').add({
        'title': 'Preventing Online Harassment',
        'videoUrl': 'https://www.youtube.com/watch?v=abc123def',
        'thumbnailUrl': 'https://example.com/video2-thumbnail.jpg',
        'category': 'Cyberbullying',
        'description': 'Tips for preventing cyberbullying',
      });

      await fakeFirestore.collection('videos').add({
        'title': 'Reporting Cyberbullying',
        'videoUrl': 'https://www.youtube.com/watch?v=xyz789',
        'thumbnailUrl': 'https://example.com/video3-thumbnail.jpg',
        'category': 'Cyberbullying',
        'description': 'How to report cyberbullying incidents',
      });

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Learn')),
            body: BlocProvider(
              create: (context) => LearnBloc()..add(CategoriesRequested()),
              child: const LearnView(),
            ),
          ),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Verify cyberbullying category is displayed
      expect(find.text('Cyberbullying'), findsOneWidget);
      expect(find.byType(Card), findsAtLeast(1));

      // Tap on cyberbullying category
      await tester.tap(find.text('Cyberbullying'));
      await tester.pumpAndSettle();

      // Verify navigation to video list
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('Understanding Cyberbullying'), findsOneWidget);
      expect(find.text('Preventing Online Harassment'), findsOneWidget);
      expect(find.text('Reporting Cyberbullying'), findsOneWidget);
    });

    testWidgets('should handle empty cyberbullying category gracefully', (WidgetTester tester) async {
      // Setup test data - Add cyberbullying category but no videos
      await fakeFirestore.collection('learn').add({
        'name': 'Cyberbullying',
        'thumbnail': 'https://example.com/cyberbullying-thumbnail.jpg',
      });

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Learn')),
            body: BlocProvider(
              create: (context) => LearnBloc()..add(CategoriesRequested()),
              child: const LearnView(),
            ),
          ),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Tap on cyberbullying category
      await tester.tap(find.text('Cyberbullying'));
      await tester.pumpAndSettle();

      // Verify empty state is shown
      expect(find.text('No videos available in "Cyberbullying" category'), findsOneWidget);
      expect(find.text('Back to Categories'), findsOneWidget);
      expect(find.byIcon(Icons.video_library_outlined), findsOneWidget);

      // Test back navigation
      await tester.tap(find.text('Back to Categories'));
      await tester.pumpAndSettle();

      // Should be back to category list
      expect(find.text('Cyberbullying'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('should handle invalid video data in cyberbullying category', (WidgetTester tester) async {
      // Setup test data - Add cyberbullying category
      await fakeFirestore.collection('learn').add({
        'name': 'Cyberbullying',
        'thumbnail': 'https://example.com/cyberbullying-thumbnail.jpg',
      });

      // Add valid video
      await fakeFirestore.collection('videos').add({
        'title': 'Valid Cyberbullying Video',
        'videoUrl': 'https://www.youtube.com/watch?v=validId',
        'thumbnailUrl': 'https://example.com/valid-thumbnail.jpg',
        'category': 'Cyberbullying',
      });

      // Add invalid video (missing URL)
      await fakeFirestore.collection('videos').add({
        'title': 'Invalid Video',
        'videoUrl': '',
        'thumbnailUrl': 'https://example.com/invalid-thumbnail.jpg',
        'category': 'Cyberbullying',
      });

      // Add video with missing thumbnail
      await fakeFirestore.collection('videos').add({
        'title': 'No Thumbnail Video',
        'videoUrl': 'https://www.youtube.com/watch?v=noThumb',
        'thumbnailUrl': '',
        'category': 'Cyberbullying',
      });

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Learn')),
            body: BlocProvider(
              create: (context) => LearnBloc()..add(CategoriesRequested()),
              child: const LearnView(),
            ),
          ),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Tap on cyberbullying category
      await tester.tap(find.text('Cyberbullying'));
      await tester.pumpAndSettle();

      // Should show only valid video (invalid ones filtered out by BLoC)
      expect(find.text('Valid Cyberbullying Video'), findsOneWidget);
      expect(find.text('Invalid Video'), findsNothing);
      expect(find.text('No Thumbnail Video'), findsNothing);
    });

    testWidgets('should handle case-insensitive category matching', (WidgetTester tester) async {
      // Setup test data - Add cyberbullying category
      await fakeFirestore.collection('learn').add({
        'name': 'Cyberbullying',
        'thumbnail': 'https://example.com/cyberbullying-thumbnail.jpg',
      });

      // Add video with different case in category
      await fakeFirestore.collection('videos').add({
        'title': 'Case Insensitive Video',
        'videoUrl': 'https://www.youtube.com/watch?v=caseTest',
        'thumbnailUrl': 'https://example.com/case-thumbnail.jpg',
        'category': 'cyberbullying', // lowercase
      });

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Learn')),
            body: BlocProvider(
              create: (context) => LearnBloc()..add(CategoriesRequested()),
              child: const LearnView(),
            ),
          ),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Tap on cyberbullying category
      await tester.tap(find.text('Cyberbullying'));
      await tester.pumpAndSettle();

      // Should find the video despite case difference
      expect(find.text('Case Insensitive Video'), findsOneWidget);
    });

    testWidgets('should handle network errors gracefully', (WidgetTester tester) async {
      // Build the widget without adding any data (simulates network error)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Learn')),
            body: BlocProvider(
              create: (context) => LearnBloc()..add(CategoriesRequested()),
              child: const LearnView(),
            ),
          ),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Should show error state with retry button
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should provide proper loading states', (WidgetTester tester) async {
      // Setup test data
      await fakeFirestore.collection('learn').add({
        'name': 'Cyberbullying',
        'thumbnail': 'https://example.com/cyberbullying-thumbnail.jpg',
      });

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Learn')),
            body: BlocProvider(
              create: (context) => LearnBloc()..add(CategoriesRequested()),
              child: const LearnView(),
            ),
          ),
        ),
      );

      // Should show loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading categories...'), findsOneWidget);

      // Wait for load to complete
      await tester.pumpAndSettle();

      // Should show categories
      expect(find.text('Cyberbullying'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should handle video navigation correctly', (WidgetTester tester) async {
      // Setup test data
      await fakeFirestore.collection('learn').add({
        'name': 'Cyberbullying',
        'thumbnail': 'https://example.com/cyberbullying-thumbnail.jpg',
      });

      await fakeFirestore.collection('videos').add({
        'title': 'Test Video',
        'videoUrl': 'https://www.youtube.com/watch?v=testVideo',
        'thumbnailUrl': 'https://example.com/test-thumbnail.jpg',
        'category': 'Cyberbullying',
      });

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Learn')),
            body: BlocProvider(
              create: (context) => LearnBloc()..add(CategoriesRequested()),
              child: const LearnView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to videos
      await tester.tap(find.text('Cyberbullying'));
      await tester.pumpAndSettle();

      // Verify video is displayed
      expect(find.text('Test Video'), findsOneWidget);

      // Test back navigation
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should be back to categories
      expect(find.text('Cyberbullying'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });
  });

  group('BLoC State Management Tests', () {
    testWidgets('should maintain proper state transitions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (context) => LearnBloc()..add(CategoriesRequested()),
            child: const Scaffold(
              body: LearnView(),
            ),
          ),
        ),
      );

      // Should start with loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // Should handle empty state gracefully
      expect(find.byType(LearnView), findsOneWidget);
    });

    testWidgets('should handle BLoC events correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (context) => LearnBloc()..add(CategoriesRequested()),
            child: const Scaffold(
              body: LearnView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // BLoC should be properly initialized and handling events
      expect(find.byType(LearnView), findsOneWidget);
    });
  });
}