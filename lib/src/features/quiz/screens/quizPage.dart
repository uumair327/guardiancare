import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guardianscare/src/constants/colors.dart';
import 'package:guardianscare/src/features/quiz/screens/quiz_questions_page.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Map<String, dynamic>> questions = [];
  List<Map<String, dynamic>> quizes = [];

  @override
  void initState() {
    super.initState();
    getQuizes();
    getQuestions();
  }

  Future<void> getQuizes() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('quizes').get();
    List<Map<String, dynamic>> _quizes = [];
    for (var doc in querySnapshot.docs) {
      if (doc["name"] != null && doc["use"]) {
        _quizes.add({
          "name": doc["name"],
          "thumbnail": doc["thumbnail"],
        });
      }
    }
    setState(() {
      quizes = _quizes;
    });
  }

  Future<void> getQuestions() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('quiz_questions').get();
    List<Map<String, dynamic>> ques = [];
    for (var doc in querySnapshot.docs) {
      if (doc["quiz"] != null) {
        ques.add({
          "quiz": doc["quiz"],
          "question": doc["question"],
          "options": doc["options"],
          "correctAnswerIndex": doc["correctOptionIndex"],
          "category": doc["category"]
        });
      }
    }
    setState(() {
      questions = ques;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Page'),
      ),
      body: ListView.builder(
        itemCount: quizes.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                // Navigate to the QuizQuestionsPage with the corresponding questions
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizQuestionsPage(
                      questions: questions
                          .where((question) =>
                              question["quiz"] == quizes[index]["name"])
                          .toList(), // Modify filtering as per your requirement
                    ),
                  ),
                );
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

  const QuizTile({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.network(
            quiz["thumbnail"],
            height: 200,
            fit: BoxFit.cover,
          ),
          Container(
              padding: EdgeInsets.all(8),
              child: Text(
                capitalizeEach(quiz["name"]),
                style: const TextStyle(
                    fontSize: 25,
                    color: tPrimaryColor,
                    fontWeight: FontWeight.w600),
              ))
        ],
      ),
    );
  }

  String capitalize(quiz) {
    if (quiz == null) return "";

    final firstLetter = quiz[0].toUpperCase();
    final restLetters = quiz.substring(1);

    return '$firstLetter$restLetters';
  }

  String capitalizeEach(quiz) {
    if (quiz == null) return "";

    final List<String> words = quiz.split(' ');

    final formatted = words.map((e) => capitalize(e)).toList();

    return formatted.join(' ');
  }
}
