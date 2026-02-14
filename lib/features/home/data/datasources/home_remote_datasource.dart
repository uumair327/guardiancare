import 'package:flutter/foundation.dart';
import 'package:guardiancare/core/backend/backend.dart';
import 'package:guardiancare/features/home/data/models/carousel_item_model.dart';

/// Abstract interface for home remote data source
abstract class HomeRemoteDataSource {
  /// Get carousel items as a stream for real-time updates
  Stream<List<CarouselItemModel>> getCarouselItems();
}

/// Implementation of home remote data source using IDataStore abstraction
///
/// Following: DIP (Dependency Inversion Principle)
/// This data source depends on IDataStore abstraction, not Firebase directly.
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {

  HomeRemoteDataSourceImpl({required IDataStore dataStore})
      : _dataStore = dataStore;
  final IDataStore _dataStore;

  @override
  Stream<List<CarouselItemModel>> getCarouselItems() {
    debugPrint('HomeRemoteDataSource: Starting to fetch carousel items...');

    return _dataStore.streamQuery('carousel_items').map((result) {
      return result.when(
        success: (docs) {
          debugPrint('HomeRemoteDataSource: Received ${docs.length} documents');

          final items = docs
              .map((doc) {
                try {
                  debugPrint('HomeRemoteDataSource: Parsing doc: $doc');
                  return CarouselItemModel.fromMap(doc);
                } on Object catch (e) {
                  debugPrint('Error parsing carousel document: $e');
                  return null;
                }
              })
              .where((item) =>
                  item != null &&
                  item.imageUrl.isNotEmpty &&
                  item.link.isNotEmpty)
              .cast<CarouselItemModel>()
              .toList();

          debugPrint(
              'HomeRemoteDataSource: Returning ${items.length} valid items');
          return items;
        },
        failure: (error) {
          debugPrint(
              'HomeRemoteDataSource: Error fetching items: ${error.message}');
          return <CarouselItemModel>[];
        },
      );
    });
  }
}
