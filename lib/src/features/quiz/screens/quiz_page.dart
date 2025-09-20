import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/quiz/quiz.dart';
import 'package:guardiancare/src/features/quiz/screens/quiz_questions_page.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});
  
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  @override
  void initState() {
    super.initState();
    // Load quizzes when page initializes
    context.read<QuizBloc>().add(const QuizLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Page'),
      ),
      body: BlocListener<QuizBloc, QuizState>(
        listener: (context, state) {
          if (state is QuizError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<QuizBloc, QuizState>(
          builder: (context, state) {
            if (state is QuizLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is QuizListLoaded) {
              if (state.quizzes.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No quizzes available.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<QuizBloc>().add(const QuizLoadRequested());
                },
                child: ListView.builder(
                  itemCount: state.quizzes.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          // Load questions for the selected quiz
                          context.read<QuizBloc>().add(
                            QuizQuestionsLoadRequested(state.quizzes[index].name),
                          );
                          
                          // Navigate to the QuizQuestionsPage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizQuestionsPage(
                                quizName: state.quizzes[index].name,
                              ),
                            ),
                          );
                        },
                        child: QuizTile(quiz: state.quizzes[index]),
                      ),
                    );
                  },
                ),
              );
            } else if (state is QuizError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<QuizBloc>().add(const QuizLoadRequested());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            
            // Default case
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class QuizTile extends StatelessWidget {
  final Quiz quiz;

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
            quiz.thumbnail,
            height: 200,
            fit: BoxFit.cover,
          ),
          Container(
              padding: const EdgeInsets.all(8),
              child: Text(
                quiz.formattedName,
                style: const TextStyle(
                    fontSize: 25,
                    color: tPrimaryColor,
                    fontWeight: FontWeight.w600),
              ))
        ],
      ),
    );
  }


}
