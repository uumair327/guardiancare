import 'package:guardiancare/core/backend/backend.dart';
import 'package:guardiancare/core/util/logger.dart';
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
  // ignore: unused_field
  final IDataStore _dataStore;

  @override
  Stream<List<CarouselItemModel>> getCarouselItems() {
    Log.d('HomeRemoteDataSource: Fetching curated carousel items...');

    // All carousel items link to Children of India website
    const items = [
      CarouselItemModel(
        id: 'children_of_india',
        type: 'image',
        imageUrl:
            'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
        link: 'https://childrenofindia.in/',
        order: 1,
      ),
      CarouselItemModel(
        id: 'childline_1098',
        type: 'image',
        imageUrl:
            'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
        link: 'https://childrenofindia.in/',
        order: 2,
      ),
      CarouselItemModel(
        id: 'education_for_all',
        type: 'image',
        imageUrl:
            'https://images.unsplash.com/photo-1509062522246-3755977927d7?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
        link: 'https://childrenofindia.in/',
        order: 3,
      ),
    ];

    return Stream.value(items);
  }
}
