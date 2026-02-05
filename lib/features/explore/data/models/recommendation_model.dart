import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiancare/features/explore/domain/entities/recommendation.dart';

class RecommendationModel extends Recommendation {
  const RecommendationModel({
    required super.id,
    required super.userId,
    required super.title,
    super.thumbnail,
    super.videoUrl,
    super.timestamp,
  });

  factory RecommendationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return RecommendationModel.fromMap(data);
  }

  factory RecommendationModel.fromMap(Map<String, dynamic> map) {
    return RecommendationModel(
      id: map['id'] ?? '',
      userId: map['UID'] ?? '',
      title: map['title'] ?? 'Untitled',
      thumbnail: map['thumbnail'],
      videoUrl: map['video'],
      timestamp: (map['timestamp'] is Timestamp)
          ? (map['timestamp'] as Timestamp).toDate()
          : (map['timestamp'] is String
              ? DateTime.tryParse(map['timestamp'])
              : null),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'UID': userId,
      'title': title,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (videoUrl != null) 'video': videoUrl,
      if (timestamp != null) 'timestamp': Timestamp.fromDate(timestamp!),
    };
  }
}
