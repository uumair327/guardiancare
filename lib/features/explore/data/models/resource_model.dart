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
    return ResourceModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      url: data['url'],
      type: data['type'],
      category: data['category'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
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
