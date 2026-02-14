import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/quiz/domain/usecases/recommendation_use_case.dart';

/// Parameters for generating recommendations
/// Requirements: 2.3
class GenerateRecommendationsParams extends Equatable {

  const GenerateRecommendationsParams({required this.categories});
  final List<String> categories;

  @override
  List<Object> get props => [categories];
}

/// Use case for generating recommendations based on quiz categories
/// 
/// This use case delegates to the RecommendationUseCase to generate
/// personalized video recommendations based on quiz results.
/// 
/// Requirements: 2.3
class GenerateRecommendations implements UseCase<void, GenerateRecommendationsParams> {

  /// Creates a GenerateRecommendations use case
  /// 
  /// [recommendationUseCase] - Optional RecommendationUseCase for delegation.
  /// If not provided, the use case will return an error.
  GenerateRecommendations([this._recommendationUseCase]);
  final RecommendationUseCase? _recommendationUseCase;

  @override
  Future<Either<Failure, void>> call(GenerateRecommendationsParams params) async {
    try {
      if (params.categories.isEmpty) {
        return const Left(ValidationFailure('Categories list cannot be empty'));
      }

      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return const Left(AuthenticationFailure('User not authenticated'));
      }

      // Delegate to RecommendationUseCase if available
      if (_recommendationUseCase != null) {
        final result = await _recommendationUseCase.call(
          RecommendationUseCaseParams(
            categories: params.categories,
            userId: user.uid,
          ),
        );

        return result.fold(
          Left.new,
          (_) => const Right(null),
        );
      }

      // Fallback error if no use case provided
      return const Left(ServerFailure('RecommendationUseCase not configured'));
    } on Object catch (e) {
      return Left(ServerFailure('Failed to generate recommendations: ${e.toString()}'));
    }
  }
}
