import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/quiz/presentation/widgets/widgets.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Map<String, dynamic>> questions = [];
  List<Map<String, dynamic>> quizes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      getQuizes(),
      getQuestions(),
    ]);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getQuizes() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('quizes').get();
      List<Map<String, dynamic>> loadedQuizes = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data["name"] != null && (data["use"] ?? false)) {
          loadedQuizes.add({
            "name": data["name"],
            "thumbnail": data["thumbnail"] ?? '',
          });
        }
      }
      if (mounted) {
        setState(() {
          quizes = loadedQuizes;
        });
      }
    } catch (e) {
      debugPrint('Error loading quizes: $e');
    }
  }

  Future<void> getQuestions() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('quiz_questions').get();
      List<Map<String, dynamic>> ques = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data["quiz"] != null) {
          ques.add({
            "quiz": data["quiz"],
            "question": data["question"],
            "options": data["options"],
            "correctAnswerIndex": data["correctOptionIndex"],
            "category": data["category"] ?? ''
          });
        }
      }
      if (mounted) {
        setState(() {
          questions = ques;
        });
      }
    } catch (e) {
      debugPrint('Error loading questions: $e');
    }
  }

  int _getQuestionCount(String quizName) {
    return questions.where((q) => q["quiz"] == quizName).length;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          // Modern header
          QuizHeader(),
          // Content
          Expanded(
            child: isLoading
                ? _buildLoadingState()
                : quizes.isEmpty
                    ? _buildEmptyState(l10n)
                    : _buildQuizGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.all(AppDimensions.screenPaddingH),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppDimensions.spaceM,
          mainAxisSpacing: AppDimensions.spaceM,
          childAspectRatio: 0.8,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          return FadeSlideWidget(
            delay: Duration(milliseconds: index * 100),
            child: ShimmerLoading(
              child: Container(
                decoration: BoxDecoration(
                  color: context.colors.surfaceVariant,
                  borderRadius: AppDimensions.borderRadiusL,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return FadeSlideWidget(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppDimensions.spaceXL),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.quiz_rounded,
                size: AppDimensions.iconXXL * 1.5,
                color: context.colors.primary,
              ),
            ),
            SizedBox(height: AppDimensions.spaceL),
            Text(
              l10n.noQuizzesAvailable,
              style: AppTextStyles.h4.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            SizedBox(height: AppDimensions.spaceS),
            Text(
              UIStrings.checkBackLaterQuizzes,
              style: AppTextStyles.body2.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizGrid() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: context.colors.primary,
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.screenPaddingH),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppDimensions.spaceM,
            mainAxisSpacing: AppDimensions.spaceM,
            childAspectRatio: 0.8,
          ),
          itemCount: quizes.length,
          itemBuilder: (context, index) {
            final quiz = quizes[index];
            final row = index ~/ 2;
            final col = index % 2;
            final delay = Duration(milliseconds: (row * 100) + (col * 50));

            return FadeSlideWidget(
              delay: delay,
              child: QuizCard(
                name: quiz["name"] ?? '',
                thumbnail: quiz["thumbnail"],
                index: index,
                questionCount: _getQuestionCount(quiz["name"]),
                onTap: () {
                  final quizQuestions = questions
                      .where((question) => question["quiz"] == quiz["name"])
                      .toList();
                  context.push('/quiz-questions', extra: quizQuestions);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
