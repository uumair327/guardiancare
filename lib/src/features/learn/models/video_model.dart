import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class VideoModel extends Equatable {
  final String id;
  final String title;
  final String videoUrl;
  final String thumbnailUrl;
  final String category;
  final String? description;

  const VideoModel({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.category,
    this.description,
  });

  @override
  List<Object?> get props => [id, title, videoUrl, thumbnailUrl, category, description];

  factory VideoModel.fromFirestore(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VideoModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      videoUrl: data['videoUrl'] as String? ?? '',
      thumbnailUrl: data['thumbnailUrl'] as String? ?? '',
      category: data['category'] as String? ?? '',
      description: data['description'] as String?,
    );
  }

  bool get isValid =>
      title.isNotEmpty &&
      videoUrl.isNotEmpty &&
      thumbnailUrl.isNotEmpty &&
      category.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'category': category,
      'description': description,
    };
  }

  VideoModel copyWith({
    String? id,
    String? title,
    String? videoUrl,
    String? thumbnailUrl,
    String? category,
    String? description,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      category: category ?? this.category,
      description: description ?? this.description,
    );
  }
}