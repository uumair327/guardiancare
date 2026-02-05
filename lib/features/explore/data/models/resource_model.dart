import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiancare/features/explore/domain/entities/resource.dart';

class ResourceModel extends Resource {
  const ResourceModel({
    required super.id,
    required super.title,
    super.description,
    super.url,
    super.type,
    super.category,
    super.timestamp,
  });

  factory ResourceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return ResourceModel.fromMap(data);
  }

  factory ResourceModel.fromMap(Map<String, dynamic> map) {
    return ResourceModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      url: map['url'],
      type: map['type'],
      category: map['category'],
      timestamp: (map['timestamp'] is Timestamp)
          ? (map['timestamp'] as Timestamp).toDate()
          : (map['timestamp'] is String
              ? DateTime.tryParse(map['timestamp'])
              : null),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      if (description != null) 'description': description,
      if (url != null) 'url': url,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (timestamp != null) 'timestamp': Timestamp.fromDate(timestamp!),
    };
  }
}
