import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiancare/features/learn/domain/entities/video_entity.dart';

/// Video model extending VideoEntity with JSON serialization
class VideoModel extends VideoEntity {
  const VideoModel({
    required super.id,
    required super.title,
    required super.videoUrl,
    required super.thumbnailUrl,
    required super.category,
    super.description,
  });

  /// Create VideoModel from Firestore document
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

  /// Convert VideoModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'category': category,
      'description': description,
    };
  }

  /// Create VideoModel from VideoEntity
  factory VideoModel.fromEntity(VideoEntity entity) {
    return VideoModel(
      id: entity.id,
      title: entity.title,
      videoUrl: entity.videoUrl,
      thumbnailUrl: entity.thumbnailUrl,
      category: entity.category,
      description: entity.description,
    );
  }
}
