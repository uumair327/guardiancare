import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/quiz/screens/quiz_questions_page.dart';

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
      if (doc["name"] != null) {
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

  const QuizTile({required this.quiz});
  

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: 
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.network(
                quiz["thumbnail"],
                height: 200,
              ),
              Container(
                padding: EdgeInsets.all(8),
                color: Color.fromRGBO(220, 220, 220, 1),
                  child: Text(
                quiz["name"],
                style: TextStyle(fontSize: 25, color: tPrimaryColor),
              ))
            ],
          ),
    );
  }
}

