import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/home/domain/entities/carousel_item_entity.dart';

/// Abstract repository interface for home feature
abstract class HomeRepository {
  /// Get carousel items as a stream for real-time updates
  Stream<Either<Failure, List<CarouselItemEntity>>> getCarouselItems();
}
