import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiancare/features/explore/domain/entities/resource_entity.dart';

/// Resource model extending ResourceEntity with Firestore serialization
class ResourceModel extends ResourceEntity {
  const ResourceModel({
    required super.title,
    required super.url,
    required super.type,
    super.timestamp,
  });

  /// Create ResourceModel from Firestore document
  factory ResourceModel.fromFirestore(Map<String, dynamic> doc) {
    return ResourceModel(
      title: doc['title'] as String? ?? 'Untitled',
      url: doc['url'] as String? ?? '',
      type: doc['type'] as String? ?? 'link',
      timestamp: doc['timestamp'] != null
          ? (doc['timestamp'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert ResourceModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'type': type,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
    };
  }

  /// Create ResourceModel from ResourceEntity
  factory ResourceModel.fromEntity(ResourceEntity entity) {
    return ResourceModel(
      title: entity.title,
      url: entity.url,
      type: entity.type,
      timestamp: entity.timestamp,
    );
  }
}
