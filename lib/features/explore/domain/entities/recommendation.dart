import 'package:equatable/equatable.dart';

class Recommendation extends Equatable {

  const Recommendation({
    required this.id,
    required this.userId,
    required this.title,
    this.thumbnail,
    this.videoUrl,
    this.timestamp,
  });
  final String id;
  final String userId;
  final String title;
  final String? thumbnail;
  final String? videoUrl;
  final DateTime? timestamp;

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        thumbnail,
        videoUrl,
        timestamp,
      ];
}
