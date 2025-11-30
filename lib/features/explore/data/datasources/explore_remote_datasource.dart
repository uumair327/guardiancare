import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiancare/features/explore/data/models/recommendation_model.dart';
import 'package:guardiancare/features/explore/data/models/resource_model.dart';

abstract class ExploreRemoteDataSource {
  Stream<List<RecommendationModel>> getRecommendations(String userId);
  Stream<List<ResourceModel>> getResources();
}

class ExploreRemoteDataSourceImpl implements ExploreRemoteDataSource {
  final FirebaseFirestore firestore;

  ExploreRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<RecommendationModel>> getRecommendations(String userId) {
    return firestore
        .collection('recommendations')
        .where('UID', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RecommendationModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Stream<List<ResourceModel>> getResources() {
    return firestore
        .collection('resources')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ResourceModel.fromFirestore(doc))
          .toList();
    }).handleError((error) {
      // Error will be handled by the repository layer
      return <ResourceModel>[];
    });
  }
}
