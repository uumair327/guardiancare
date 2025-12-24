import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
    debugPrint('HomeRemoteDataSource: Starting to fetch carousel items...');
    
    return firestore.collection('carousel_items').snapshots().map((snapshot) {
      debugPrint('HomeRemoteDataSource: Received ${snapshot.docs.length} documents');
      
      final items = snapshot.docs
          .map((doc) {
            try {
              debugPrint('HomeRemoteDataSource: Parsing doc ${doc.id}: ${doc.data()}');
              return CarouselItemModel.fromFirestore(doc);
            } catch (e) {
              debugPrint('Error parsing carousel document ${doc.id}: $e');
              return null;
            }
          })
          .where((item) =>
              item != null &&
              item.imageUrl.isNotEmpty &&
              item.link.isNotEmpty)
          .cast<CarouselItemModel>()
          .toList();
      
      debugPrint('HomeRemoteDataSource: Returning ${items.length} valid items');
      return items;
    });
  }
}
