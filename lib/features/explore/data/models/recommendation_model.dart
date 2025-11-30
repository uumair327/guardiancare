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
    return RecommendationModel(
      id: doc.id,
      userId: data['UID'] ?? '',
      title: data['title'] ?? 'Untitled',
      thumbnail: data['thumbnail'],
      videoUrl: data['video'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
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
