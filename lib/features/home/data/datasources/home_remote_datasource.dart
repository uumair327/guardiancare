import 'package:guardiancare/core/backend/backend.dart';
import 'package:guardiancare/core/util/logger.dart';
import 'package:guardiancare/features/home/data/models/carousel_item_model.dart';

/// Abstract interface for home remote data source
// ignore: one_member_abstracts
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
  // ignore: unused_field
  final IDataStore _dataStore;

  @override
  Stream<List<CarouselItemModel>> getCarouselItems() {
    Log.d(
        'HomeRemoteDataSource: Fetching curated carousel items from database...');

    return _dataStore.streamQuery('carousel_items').map((result) {
      return result.when(
        success: (docs) {
          final List<CarouselItemModel> items = [];
          for (final doc in docs) {
            try {
              // Ensure doc contains ID, many mappers assume 'id' is present
              if (!doc.containsKey('id') && doc.containsKey('_id')) {
                doc['id'] = doc['_id'];
              }
              items.add(CarouselItemModel.fromMap(doc));
            } on Object catch (e) {
              Log.e('HomeRemoteDataSource: Error processing carousel item: $e');
            }
          }

          // Filter and sort on the client side to bypass Firestore composite index requirements
          final activeItems = items.where((item) => item.isActive).toList();
          activeItems.sort((a, b) => a.order.compareTo(b.order));

          Log.d(
              'HomeRemoteDataSource: Emitting ${activeItems.length} active carousel items');
          return activeItems;
        },
        failure: (error) {
          Log.e('HomeRemoteDataSource: Stream error: ${error.message}');
          return <CarouselItemModel>[];
        },
      );
    });
  }
}
