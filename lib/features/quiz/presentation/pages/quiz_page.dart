import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/core/di/di.dart' as di;
import 'package:guardiancare/core/util/logger.dart';
import 'package:guardiancare/features/quiz/domain/entities/quiz_entity.dart';
import 'package:guardiancare/features/quiz/domain/usecases/get_all_quizzes.dart';
import 'package:guardiancare/features/quiz/presentation/widgets/widgets.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<QuizEntity> quizzes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    final usecase = di.sl<GetAllQuizzes>();
    final result = await usecase(NoParams());

    if (mounted) {
      result.fold((failure) {
        Log.e('Error loading quizzes: ${failure.message}');
        setState(() {
          isLoading = false;
        });
      }, (data) {
        setState(() {
          quizzes = data;
          isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          // Modern header
          const QuizHeader(),
          // Content
          Expanded(
            child: isLoading
                ? _buildLoadingState()
                : quizzes.isEmpty
                    ? _buildEmptyState(l10n)
                    : _buildQuizGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppDimensions.spaceM,
          mainAxisSpacing: AppDimensions.spaceM,
          childAspectRatio: 0.8,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return FadeSlideWidget(
            delay: Duration(milliseconds: index * 100),
            child: ShimmerLoading(
              child: Container(
                decoration: BoxDecoration(
                  color: context.colors.surfaceVariant,
                  borderRadius: AppDimensions.borderRadiusL,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: AppDimensions.spaceM,
                      right: AppDimensions.spaceM,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
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
              padding: const EdgeInsets.all(AppDimensions.spaceXL),
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
            const SizedBox(height: AppDimensions.spaceL),
            Text(
              l10n.noQuizzesAvailable,
              style: AppTextStyles.h4.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceS),
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
      onRefresh: _loadQuizzes,
      color: context.colors.primary,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppDimensions.spaceM,
            mainAxisSpacing: AppDimensions.spaceM,
            childAspectRatio: 0.8,
          ),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            final row = index ~/ 2;
            final col = index % 2;
            final delay = Duration(milliseconds: (row * 100) + (col * 50));

            return FadeSlideWidget(
              delay: delay,
              child: QuizCard(
                name: quiz.title,
                thumbnail: quiz.imageUrl,
                index: index,
                questionCount: quiz.questions.length,
                onTap: () {
                  context.push('/quiz-questions', extra: quiz.questions);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
