import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiancare/features/home/data/models/carousel_item_model.dart';

/// Abstract interface for home remote data source
abstract class HomeRemoteDataSource {
  /// Get carousel items as a stream for real-time updates
  Stream<List<CarouselItemModel>> getCarouselItems();
}

/// Implementation of home remote data source using Firebase Firestore
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final FirebaseFirestore firestore;

  HomeRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<CarouselItemModel>> getCarouselItems() {
    return firestore.collection('carousel_items').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return CarouselItemModel.fromFirestore(doc);
            } catch (e) {
              return null;
            }
          })
          .where((item) =>
              item != null &&
              item.imageUrl.isNotEmpty &&
              item.link.isNotEmpty)
          .cast<CarouselItemModel>()
          .toList();
    });
  }
}
