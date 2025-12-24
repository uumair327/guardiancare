import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';

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
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('quiz_questions')
          .get();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quiz),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: SafeArea(
        child: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : quizes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.quiz,
                        size: AppDimensions.iconXXL * 1.5,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: AppDimensions.spaceL),
                      Text(
                        l10n.noQuizzesAvailable,
                        style: AppTextStyles.h5.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: quizes.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: EdgeInsets.all(AppDimensions.spaceS),
                      child: InkWell(
                        onTap: () {
                          final quizQuestions = questions
                              .where((question) =>
                                  question["quiz"] == quizes[index]["name"])
                              .toList();
                          context.push('/quiz-questions', extra: quizQuestions);
                        },
                        child: QuizTile(quiz: quizes[index]),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}

class QuizTile extends StatelessWidget {
  final Map<String, dynamic> quiz;

  const QuizTile({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.cardElevation,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (quiz["thumbnail"] != null && quiz["thumbnail"].isNotEmpty)
            Image.network(
              quiz["thumbnail"],
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: AppColors.divider,
                  child: Icon(
                    Icons.quiz,
                    size: AppDimensions.iconXXL,
                    color: AppColors.primary,
                  ),
                );
              },
            ),
          Container(
            padding: EdgeInsets.all(AppDimensions.spaceS),
            child: Text(
              capitalizeEach(quiz["name"]),
              style: AppTextStyles.h3.copyWith(
                color: AppColors.primary,
              ),
            ),
          )
        ],
      ),
    );
  }

  String capitalize(String? text) {
    if (text == null || text.isEmpty) return "";
    final firstLetter = text[0].toUpperCase();
    final restLetters = text.substring(1);
    return '$firstLetter$restLetters';
  }

  String capitalizeEach(String? text) {
    if (text == null || text.isEmpty) return "";
    final List<String> words = text.split(' ');
    final formatted = words.map((e) => capitalize(e)).toList();
    return formatted.join(' ');
  }
}
