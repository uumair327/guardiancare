import 'package:guardiancare/core/backend/backend.dart';
import 'package:guardiancare/features/explore/data/models/recommendation_model.dart';
import 'package:guardiancare/features/explore/data/models/resource_model.dart';

abstract class ExploreRemoteDataSource {
  Stream<List<RecommendationModel>> getRecommendations(String userId);
  Stream<List<ResourceModel>> getResources();
}

class ExploreRemoteDataSourceImpl implements ExploreRemoteDataSource {

  ExploreRemoteDataSourceImpl({required IDataStore dataStore})
      : _dataStore = dataStore;
  final IDataStore _dataStore;

  @override
  Stream<List<RecommendationModel>> getRecommendations(String userId) {
    final options = QueryOptions(
      filters: [QueryFilter.equals('UID', userId)],
      orderBy: [const OrderBy('timestamp', descending: true)],
    );

    return _dataStore
        .streamQuery('recommendations', options: options)
        .map((result) {
      return result.when(
        success: (docs) =>
            docs.map(RecommendationModel.fromMap).toList(),
        failure: (error) {
          // Provide feedback or log error? Returning empty list for now matching safe stream behavior
          return <RecommendationModel>[];
        },
      );
    });
  }

  @override
  Stream<List<ResourceModel>> getResources() {
    return _dataStore.streamQuery('resources').map((result) {
      return result.when(
        success: (docs) =>
            docs.map(ResourceModel.fromMap).toList(),
        failure: (error) => <ResourceModel>[],
      );
    });
  }
}
