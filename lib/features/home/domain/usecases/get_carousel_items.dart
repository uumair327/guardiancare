import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/home/domain/entities/carousel_item_entity.dart';
import 'package:guardiancare/features/home/domain/repositories/home_repository.dart';

/// Use case for getting carousel items
/// Returns a stream for real-time updates from Firestore
class GetCarouselItems extends StreamUseCase<List<CarouselItemEntity>, NoParams> {

  GetCarouselItems(this.repository);
  final HomeRepository repository;

  @override
  Stream<Either<Failure, List<CarouselItemEntity>>> call(NoParams params) {
    return repository.getCarouselItems();
  }
}
