import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/home/data/datasources/home_remote_datasource.dart';
import 'package:guardiancare/features/home/domain/entities/carousel_item_entity.dart';
import 'package:guardiancare/features/home/domain/repositories/home_repository.dart';

/// Implementation of HomeRepository
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, List<CarouselItemEntity>>> getCarouselItems() {
    try {
      return remoteDataSource.getCarouselItems().map(
        (items) {
          return Right<Failure, List<CarouselItemEntity>>(items);
        },
      ).handleError((error) {
        return Left<Failure, List<CarouselItemEntity>>(
          ServerFailure('Failed to load carousel items: ${error.toString()}'),
        );
      });
    } catch (e) {
      return Stream.value(
        Left<Failure, List<CarouselItemEntity>>(
          ServerFailure('Failed to load carousel items: ${e.toString()}'),
        ),
      );
    }
  }
}
