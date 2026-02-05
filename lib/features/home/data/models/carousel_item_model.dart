import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiancare/features/home/domain/entities/carousel_item_entity.dart';

/// Data model for carousel items extending the domain entity
class CarouselItemModel extends CarouselItemEntity {
  const CarouselItemModel({
    required super.id,
    required super.type,
    required super.imageUrl,
    required super.link,
    super.thumbnailUrl,
    super.content,
    super.order,
    super.isActive,
  });

  /// Create model from Firestore document
  factory CarouselItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CarouselItemModel(
      id: doc.id,
      type: data['type'] ?? 'image',
      imageUrl: data['imageUrl'] ?? '',
      link: data['link'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      content: data['content'] ?? {},
      order: data['order'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }

  /// Create model from Map (alias for fromJson, used by IDataStore)
  factory CarouselItemModel.fromMap(Map<String, dynamic> map) {
    return CarouselItemModel.fromJson(map);
  }

  /// Create model from JSON
  factory CarouselItemModel.fromJson(Map<String, dynamic> json) {
    return CarouselItemModel(
      id: json['id'] ?? '',
      type: json['type'] ?? 'image',
      imageUrl: json['imageUrl'] ?? '',
      link: json['link'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      content: json['content'] ?? {},
      order: json['order'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'imageUrl': imageUrl,
      'link': link,
      'thumbnailUrl': thumbnailUrl,
      'content': content,
      'order': order,
      'isActive': isActive,
    };
  }

  /// Convert model to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'imageUrl': imageUrl,
      'link': link,
      'thumbnailUrl': thumbnailUrl,
      'content': content,
      'order': order,
      'isActive': isActive,
    };
  }
}
