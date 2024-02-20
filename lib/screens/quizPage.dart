import 'package:flutter/material.dart';
import 'package:myapp/screens/quizQuestionsPage.dart';

class QuizPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Create a list of quizzes
    List<Quiz> quizzes = [
      Quiz(
        imageUrl: 'assets/images/image.png',
        title: 'Quiz 1',
        description: 'This is a quiz on child abuse.',
        questions: [
          {
            'question': 'What is the most common form of child abuse?',
            'options': [
              'Physical abuse',
              'Emotional abuse',
              'Neglect',
              'Sexual abuse'
            ],
            'correctAnswerIndex': 2,
          },
          {
            'question': 'Who are the most common perpetrators of child abuse?',
            'options': [
              'Strangers',
              'Parents',
              'Teachers',
              'Police officers'
            ],
            'correctAnswerIndex': 1,
          },
          {
            'question': 'What percentage of children experience some form of abuse or neglect during their lifetime?',
            'options': [
              '5%',
              '10%',
              '20%',
              '30%'
            ],
            'correctAnswerIndex': 3,
          },
          {
            'question': 'What is the first step to preventing child abuse?',
            'options': [
              'Reporting suspected abuse',
              'Educating children about abuse',
              'Providing therapy for victims',
              'Punishing abusers'
            ],
            'correctAnswerIndex': 0,
          },
          {
            'question': 'What is the most important thing for parents to do to prevent abuse?',
            'options': [
              'Keep children under constant supervision',
              'Teach children about personal safety',
              'Provide discipline when needed',
              'Ignore signs of abuse'
            ],
            'correctAnswerIndex': 1,
          },
          {
            'question': 'What is the impact of child abuse on victims?',
            'options': [
              'Long-term physical health problems',
              'Emotional and psychological issues',
              'Difficulty forming relationships',
              'All of the above'
            ],
            'correctAnswerIndex': 3,
          },
          {
            'question': 'What is the legal obligation regarding reporting child abuse?',
            'options': [
              'Optional',
              'Mandatory',
              'Depends on the severity',
              'Depends on the relationship with the victim'
            ],
            'correctAnswerIndex': 1,
          },
          {
            'question': 'What are common signs of child abuse?',
            'options': [
              'Unexplained injuries',
              'Withdrawn behavior',
              'Fear of going home',
              'All of the above'
            ],
            'correctAnswerIndex': 3,
          },
          {
            'question': 'What is the role of bystanders in preventing child abuse?',
            'options': [
              'Not relevant',
              'Report suspected abuse',
              'Intervene in abusive situations',
              'Ignore the situation'
            ],
            'correctAnswerIndex': 1,
          },
          {
            'question': 'How can communities support victims of child abuse?',
            'options': [
              'Provide counseling services',
              'Offer safe shelters',
              'Educate the public about abuse',
              'All of the above'
            ],
            'correctAnswerIndex': 3,
          },
        ],
      ),
      Quiz(
        imageUrl: 'assets/images/image.png',
        title: 'Quiz 2',
        description: 'This is a quiz on sexual exploitation.',
        questions: [
          {
            'question': 'What is sexual exploitation?',
            'options': [
              'Physical violence',
              'Mental manipulation',
              'Using a person for sexual purposes',
              'Emotional neglect'
            ],
            'correctAnswerIndex': 2,
          },
          {
            'question': 'Who are vulnerable to sexual exploitation?',
            'options': [
              'Adults',
              'Teenagers',
              'Children',
              'Elderly people'
            ],
            'correctAnswerIndex': 2,
          },
          {
            'question': 'What are the signs of sexual exploitation?',
            'options': [
              'Physical injuries',
              'Fear of certain people',
              'Unexplained gifts',
              'All of the above'
            ],
            'correctAnswerIndex': 3,
          },
          {
            'question': 'How can sexual exploitation be prevented?',
            'options': [
              'Raising awareness',
              'Legal punishment',
              'Increased security measures',
              'All of the above'
            ],
            'correctAnswerIndex': 0,
          },
          {
            'question': 'What role does grooming play in sexual exploitation?',
            'options': [
              'It is a form of punishment',
              'It is a way to gain trust and manipulate victims',
              'It is a method of physical violence',
              'It is a form of therapy'
            ],
            'correctAnswerIndex': 1,
          },
          {
            'question': 'Who are the perpetrators of sexual exploitation?',
            'options': [
              'Strangers',
              'Family members',
              'Teachers',
              'Doctors'
            ],
            'correctAnswerIndex': 1,
          },
          {
            'question': 'What is the impact of sexual exploitation on victims?',
            'options': [
              'Physical injuries',
              'Mental health issues',
              'Social isolation',
              'All of the above'
            ],
            'correctAnswerIndex': 3,
          },
          {
            'question': 'What are some common tactics used by sexual exploiters?',
            'options': [
              'Offering money or gifts',
              'Threats or intimidation',
              'Manipulation and coercion',
              'All of the above'
            ],
            'correctAnswerIndex': 3,
          },
          {
            'question': 'How can communities help prevent sexual exploitation?',
            'options': [
              'Providing support services',
              'Educating the public',
              'Promoting healthy relationships',
              'All of the above'
            ],
            'correctAnswerIndex': 3,
          },
          {
            'question': 'What should a person do if they suspect sexual exploitation?',
            'options': [
              'Ignore the situation',
              'Keep it to themselves',
              'Report it to authorities',
              'Confront the suspect'
            ],
            'correctAnswerIndex': 2,
          },
        ],
      ),
      Quiz(
        imageUrl: 'assets/images/image.png',
        title: 'Quiz 3',
        description: 'This is a quiz on cyberbullying.',
        questions: [
          {
            'question': 'What is cyberbullying?',
            'options': [
              'Bullying that occurs in schools',
              'Bullying that takes place over the internet or via digital devices',
              'Bullying that happens during outdoor activities',
              'Bullying that happens in the workplace'
            ],
            'correctAnswerIndex': 1,
          },
          {
            'question': 'What are common forms of cyberbullying?',
            'options': [
              'Sending mean text messages or emails',
              'Spreading rumors online',
              'Posting hurtful comments on social media',
              'All of the above'
            ],
            'correctAnswerIndex': 3,
          },
          {
            'question': 'How can cyberbullying affect its victims?',
            'options': [
              'Increased self-esteem',
              'Emotional distress and mental health issues',
              'Improved social relationships',
              'All of the above'
            ],
            'correctAnswerIndex': 1,
          },
          {
            'question': 'What steps can be taken to prevent cyberbullying?',
            'options': [
              'Ignoring the problem',
              'Promoting kindness and empathy online',
              'Encouraging anonymity on social media platforms',
              'All of the above'
            ],
            'correctAnswerIndex': 1,
          },
          {
            'question': 'Who can be cyberbullies?',
            'options': [
              'Strangers only',
              'Peers, friends, or acquaintances',
              'Family members only',
              'Teachers or authority figures'
            ],
            'correctAnswerIndex': 1,
          },
          {
            'question': 'What should victims of cyberbullying do?',
            'options': [
              'Retaliate with equal force',
              'Keep quiet and endure the bullying',
              'Reach out for help and support',
              'Become cyberbullies themselves'
            ],
            'correctAnswerIndex': 2,
          },
          {
            'question': 'Why is cyberbullying harmful?',
            'options': [
              'Its just harmless fun',
              'It can lead to serious consequences such as depression and suicide',
              'Its a normal part of growing up',
              'It helps build character'
            ],
            'correctAnswerIndex': 1,
          },
          {
            'question': 'What role do bystanders play in cyberbullying?',
            'options': [
              'They are not involved',
              'They can intervene and support the victim',
              'They should join in the bullying',
              'They should stay silent'
            ],
            'correctAnswerIndex': 1,
          },
          {
            'question': 'How can parents help prevent cyberbullying?',
            'options': [
              "Monitor their children's online activities",
              'Teach their children about responsible online behavior',
              'Encourage open communication about online experiences',
              'All of the above'
            ],
            'correctAnswerIndex': 3,
          },
          {
            'question': 'What should schools do to address cyberbullying?',
            'options': [
              "Ignore it as it's not their responsibility",
              'Provide education and resources on cyberbullying prevention',
              'Punish the victims for being targeted',
              'None of the above'
            ],
            'correctAnswerIndex': 1,
          },
        ],
      ),
      // Add more quizzes here
      // ...
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Page'),
      ),
      body: ListView.builder(
        itemCount: quizzes.length,
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
                      questions: quizzes[index].questions,
                    ),
                  ),
                );
              },
              child: QuizTile(quiz: quizzes[index]),
            ),
          );
        },
      ),
    );
  }
}

class QuizTile extends StatelessWidget {
  final Quiz quiz;

  const QuizTile({required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              quiz.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  quiz.description,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Quiz {
  final String imageUrl;
  final String title;
  final String description;
  final List<Map<String, dynamic>> questions;

  Quiz({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.questions,
  });
}
