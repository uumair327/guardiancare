import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:guardiancare/core/constants/constants.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/home/data/datasources/home_remote_datasource.dart';
import 'package:guardiancare/features/home/domain/entities/carousel_item_entity.dart';
import 'package:guardiancare/features/home/domain/repositories/home_repository.dart';

/// Implementation of HomeRepository
class HomeRepositoryImpl implements HomeRepository {

  HomeRepositoryImpl({required this.remoteDataSource});
  final HomeRemoteDataSource remoteDataSource;

  @override
  Stream<Either<Failure, List<CarouselItemEntity>>> getCarouselItems() {
    debugPrint('HomeRepositoryImpl: getCarouselItems called');
    
    return remoteDataSource.getCarouselItems()
      .map<Either<Failure, List<CarouselItemEntity>>>((items) {
        debugPrint('HomeRepositoryImpl: Received ${items.length} items from data source');
        return Right<Failure, List<CarouselItemEntity>>(items);
      })
      .transform(StreamTransformer<Either<Failure, List<CarouselItemEntity>>, Either<Failure, List<CarouselItemEntity>>>.fromHandlers(
        handleData: (data, sink) => sink.add(data),
        handleError: (error, stackTrace, sink) {
          debugPrint('HomeRepositoryImpl: Error occurred: $error');
          sink.add(Left<Failure, List<CarouselItemEntity>>(
            ServerFailure(ErrorStrings.withDetails(ErrorStrings.loadCarouselItemsError, error.toString())),
          ));
        },
      ));
  }
}
