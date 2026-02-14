import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiancare/features/explore/domain/entities/video_entity.dart';

/// Video model extending VideoEntity with Firestore serialization
class VideoModel extends VideoEntity {
  const VideoModel({
    required super.thumbnail,
    required super.title,
    required super.videoUrl,
    super.category,
    super.timestamp,
  });

  /// Create VideoModel from VideoEntity
  factory VideoModel.fromEntity(VideoEntity entity) {
    return VideoModel(
      thumbnail: entity.thumbnail,
      title: entity.title,
      videoUrl: entity.videoUrl,
      category: entity.category,
      timestamp: entity.timestamp,
    );
  }

  /// Create VideoModel from Firestore document
  factory VideoModel.fromFirestore(Map<String, dynamic> doc) {
    return VideoModel(
      thumbnail: doc['thumbnail'] as String? ?? '',
      title: doc['title'] as String? ?? 'Untitled',
      videoUrl: doc['video'] as String? ?? doc['videoUrl'] as String? ?? '',
      category: doc['category'] as String?,
      timestamp: doc['timestamp'] is Timestamp
          ? (doc['timestamp'] as Timestamp).toDate()
          : (doc['timestamp'] is String
              ? DateTime.tryParse(doc['timestamp'])
              : null),
    );
  }

  /// Convert VideoModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'thumbnail': thumbnail,
      'title': title,
      'video': videoUrl,
      'category': category,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
    };
  }
}
