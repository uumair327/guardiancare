import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/quiz/domain/repositories/quiz_repository.dart';

class SaveQuizHistoryParams extends Equatable {
  final String uid;
  final String quizName;
  final int score;
  final int totalQuestions;
  final List<String> categories;

  const SaveQuizHistoryParams({
    required this.uid,
    required this.quizName,
    required this.score,
    required this.totalQuestions,
    required this.categories,
  });

  @override
  List<Object> get props => [uid, quizName, score, totalQuestions, categories];
}

class SaveQuizHistory implements UseCase<void, SaveQuizHistoryParams> {
  final QuizRepository repository;

  SaveQuizHistory(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveQuizHistoryParams params) async {
    return await repository.saveQuizHistory(
      uid: params.uid,
      quizName: params.quizName,
      score: params.score,
      totalQuestions: params.totalQuestions,
      categories: params.categories,
    );
  }
}
