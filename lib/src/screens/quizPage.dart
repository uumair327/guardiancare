import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/features/quiz/screens/quiz_questions_page.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Map<String, dynamic>> questions = [];

  @override
  void initState() {
    super.initState();
    getQuestions();
  }

  Future<void> getQuestions() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('questions').get();
    List<Map<String, dynamic>> ques = [];
    for (var doc in querySnapshot.docs) {
      if (doc["quiz"] != null) {
        ques.add({
          "quiz": doc["quiz"],
          "question": doc["question"],
          "options": doc["options"],
          "correctAnswerIndex": doc["correctOptionIndex"],
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
        itemCount: questions.length,
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
                          .where(
                              (question) => question["quiz"] == "child abuse")
                          .toList(), // Modify filtering as per your requirement
                    ),
                  ),
                );
              },
              child: QuizTile(question: questions[index]),
            ),
          );
        },
      ),
    );
  }
}

class QuizTile extends StatelessWidget {
  final Map<String, dynamic> question;

  const QuizTile({required this.question});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ListTile(
        title: Text(question['question']),
        subtitle: Text('Quiz: ${question['quiz']}'),
      ),
    );
  }
}
