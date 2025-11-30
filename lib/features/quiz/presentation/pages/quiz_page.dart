import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/constants/app_colors.dart';
import 'package:guardiancare/core/l10n/generated/app_localizations.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);

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
      List<Map<String, dynamic>> _quizes = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data["name"] != null && (data["use"] ?? false)) {
          _quizes.add({
            "name": data["name"],
            "thumbnail": data["thumbnail"] ?? '',
          });
        }
      }
      if (mounted) {
        setState(() {
          quizes = _quizes;
        });
      }
    } catch (e) {
      print('Error loading quizes: $e');
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
      print('Error loading questions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quiz),
        backgroundColor: tPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : quizes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.quiz, size: 100, color: Colors.grey),
                      const SizedBox(height: 20),
                      Text(
                        l10n.noQuizzesAvailable,
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: quizes.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
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
    );
  }
}

class QuizTile extends StatelessWidget {
  final Map<String, dynamic> quiz;

  const QuizTile({Key? key, required this.quiz}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
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
                  color: Colors.grey[300],
                  child: const Icon(Icons.quiz, size: 64, color: tPrimaryColor),
                );
              },
            ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              capitalizeEach(quiz["name"]),
              style: const TextStyle(
                fontSize: 25,
                color: tPrimaryColor,
                fontWeight: FontWeight.w600,
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
