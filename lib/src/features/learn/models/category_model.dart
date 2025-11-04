import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final String name;
  final String thumbnail;

  const CategoryModel({
    required this.name,
    required this.thumbnail,
  });

  @override
  List<Object> get props => [name, thumbnail];

  factory CategoryModel.fromFirestore(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      name: data['name'] as String? ?? '',
      thumbnail: data['thumbnail'] as String? ?? '',
    );
  }

  bool get isValid => name.isNotEmpty && thumbnail.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'thumbnail': thumbnail,
    };
  }

  CategoryModel copyWith({
    String? name,
    String? thumbnail,
  }) {
    return CategoryModel(
      name: name ?? this.name,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }
}