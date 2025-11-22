import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/learn/domain/entities/category_entity.dart';
import 'package:guardiancare/features/learn/domain/entities/video_entity.dart';

/// Learn repository interface defining learning operations
abstract class LearnRepository {
  /// Get all learning categories
  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  /// Get videos by category
  Future<Either<Failure, List<VideoEntity>>> getVideosByCategory(
      String category);

  /// Get videos by category as a stream for real-time updates
  Stream<Either<Failure, List<VideoEntity>>> getVideosByCategoryStream(
      String category);
}
