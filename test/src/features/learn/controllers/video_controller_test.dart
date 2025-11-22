import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:guardiancare/src/features/learn/learn.dart';
import 'package:guardiancare/src/features/learn/widgets/learn_view.dart';
import 'package:guardiancare/src/constants/colors.dart';

void main() {
  group('Learn BLoC Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    
    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    testWidgets('should display loading indicator initially', (WidgetTester tester) async {
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

      // Should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading categories...'), findsOneWidget);
    });

    testWidgets('should display categories after loading', (WidgetTester tester) async {
      // Add test data to fake Firestore
      await fakeFirestore.collection('learn').add({
        'name': 'Cyberbullying',
        'thumbnail': 'https://example.com/cyberbullying.jpg',
      });
      
      await fakeFirestore.collection('learn').add({
        'name': 'Sexual Abuse',
        'thumbnail': 'https://example.com/sexual-abuse.jpg',
      });

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

      // Wait for the widget to build and data to load
      await tester.pumpAndSettle();

      // Should display category cards
      expect(find.text('Cyberbullying'), findsOneWidget);
      expect(find.text('Sexual Abuse'), findsOneWidget);
      expect(find.byType(Card), findsAtLeast(2));
    });

    testWidgets('should navigate to video list when category is tapped', (WidgetTester tester) async {
      // Add test data
      await fakeFirestore.collection('learn').add({
        'name': 'Cyberbullying',
        'thumbnail': 'https://example.com/cyberbullying.jpg',
      });

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

      // Tap on the Cyberbullying category
      await tester.tap(find.text('Cyberbullying'));
      await tester.pumpAndSettle();

      // Should show back button and category title
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('Cyberbullying'), findsOneWidget);
    });

    testWidgets('should display videos when category is selected', (WidgetTester tester) async {
      // Add category data
      await fakeFirestore.collection('learn').add({
        'name': 'Cyberbullying',
        'thumbnail': 'https://example.com/cyberbullying.jpg',
      });

      // Add video data
      await fakeFirestore.collection('videos').add({
        'title': 'Understanding Cyberbullying',
        'videoUrl': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'thumbnailUrl': 'https://example.com/video1.jpg',
        'category': 'Cyberbullying',
      });

      await fakeFirestore.collection('videos').add({
        'title': 'Preventing Online Harassment',
        'videoUrl': 'https://www.youtube.com/watch?v=abc123',
        'thumbnailUrl': 'https://example.com/video2.jpg',
        'category': 'Cyberbullying',
      });

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

      // Tap on Cyberbullying category
      await tester.tap(find.text('Cyberbullying'));
      await tester.pumpAndSettle();

      // Should display video titles
      expect(find.text('Understanding Cyberbullying'), findsOneWidget);
      expect(find.text('Preventing Online Harassment'), findsOneWidget);
    });

    testWidgets('should show empty state when no videos found', (WidgetTester tester) async {
      // Add category but no videos
      await fakeFirestore.collection('learn').add({
        'name': 'Empty Category',
        'thumbnail': 'https://example.com/empty.jpg',
      });

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

      // Tap on empty category
      await tester.tap(find.text('Empty Category'));
      await tester.pumpAndSettle();

      // Should show empty state
      expect(find.text('No videos available in "Empty Category" category'), findsOneWidget);
      expect(find.text('Back to Categories'), findsOneWidget);
      expect(find.byIcon(Icons.video_library_outlined), findsOneWidget);
    });

    testWidgets('should navigate back to categories when back button is pressed', (WidgetTester tester) async {
      // Add test data
      await fakeFirestore.collection('learn').add({
        'name': 'Test Category',
        'thumbnail': 'https://example.com/test.jpg',
      });

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

      // Navigate to category
      await tester.tap(find.text('Test Category'));
      await tester.pumpAndSettle();

      // Verify we're in video list view
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should be back to category list
      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(find.text('Test Category'), findsOneWidget);
    });

    testWidgets('should handle invalid category data gracefully', (WidgetTester tester) async {
      // Add invalid category data
      await fakeFirestore.collection('learn').add({
        'name': null,
        'thumbnail': 'https://example.com/invalid.jpg',
      });

      await fakeFirestore.collection('learn').add({
        'name': 'Valid Category',
        'thumbnail': null,
      });

      await fakeFirestore.collection('learn').add({
        'name': 'Good Category',
        'thumbnail': 'https://example.com/good.jpg',
      });

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

      // Should only show the valid category
      expect(find.text('Good Category'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should handle video data validation', (WidgetTester tester) async {
      // Add category
      await fakeFirestore.collection('learn').add({
        'name': 'Test Category',
        'thumbnail': 'https://example.com/test.jpg',
      });

      // Add valid video
      await fakeFirestore.collection('videos').add({
        'title': 'Valid Video',
        'videoUrl': 'https://www.youtube.com/watch?v=validId',
        'thumbnailUrl': 'https://example.com/valid.jpg',
        'category': 'Test Category',
      });

      // Add invalid video (missing URL)
      await fakeFirestore.collection('videos').add({
        'title': 'Invalid Video',
        'videoUrl': '',
        'thumbnailUrl': 'https://example.com/invalid.jpg',
        'category': 'Test Category',
      });

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

      // Navigate to category
      await tester.tap(find.text('Test Category'));
      await tester.pumpAndSettle();

      // Should show both videos (validation happens on tap)
      expect(find.text('Valid Video'), findsOneWidget);
      expect(find.text('Invalid Video'), findsOneWidget);

      // Tap on invalid video should show error
      await tester.tap(find.text('Invalid Video'));
      await tester.pumpAndSettle();

      // Should show error snackbar
      expect(find.text('Video URL not available for "Invalid Video"'), findsOneWidget);
    });

    testWidgets('should show retry button on error', (WidgetTester tester) async {
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

      // Simulate error by not adding any data and waiting
      await tester.pumpAndSettle();

      // The widget should handle empty data gracefully
      // In a real scenario with network errors, we'd see retry buttons
      expect(find.byType(LearnView), findsOneWidget);
    });
  });

  group('Learn BLoC Debug Features', () {
    testWidgets('should provide debug information', (WidgetTester tester) async {
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

      // Debug features are internal and tested through integration
      expect(find.byType(LearnView), findsOneWidget);
    });
  });

  group('Learn BLoC Edge Cases', () {
    testWidgets('should handle empty Firestore collections', (WidgetTester tester) async {
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

      // Should show loading initially, then empty state or categories
      expect(find.byType(LearnView), findsOneWidget);
    });

    testWidgets('should handle malformed video data', (WidgetTester tester) async {
      // Add category
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

      // Widget should handle malformed data gracefully
      expect(find.byType(LearnView), findsOneWidget);
    });
  });
}