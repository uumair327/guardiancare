import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiancare/features/learn/domain/entities/category_entity.dart';

/// Category model extending CategoryEntity with JSON serialization
class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.name,
    required super.thumbnail,
  });

  /// Create CategoryModel from Firestore document
  factory CategoryModel.fromFirestore(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      name: data['name'] as String? ?? '',
      thumbnail: data['thumbnail'] as String? ?? '',
    );
  }

  /// Create CategoryModel from Map (for IDataStore)
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      name: map['name'] as String? ?? '',
      thumbnail: map['thumbnail'] as String? ?? '',
    );
  }

  /// Convert CategoryModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'thumbnail': thumbnail,
    };
  }

  /// Create CategoryModel from CategoryEntity
  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      name: entity.name,
      thumbnail: entity.thumbnail,
    );
  }
}
