import 'package:equatable/equatable.dart';

/// Domain entity representing a carousel item on the home page
class CarouselItemEntity extends Equatable {

  const CarouselItemEntity({
    required this.id,
    required this.type,
    required this.imageUrl,
    required this.link,
    this.thumbnailUrl = '',
    this.content = const {},
    this.order = 0,
    this.isActive = true,
  });
  final String id;
  final String type; // 'image', 'video', or 'custom'
  final String imageUrl;
  final String link;
  final String thumbnailUrl;
  final Map<String, dynamic> content;
  final int order;
  final bool isActive;

  @override
  List<Object?> get props => [
        id,
        type,
        imageUrl,
        link,
        thumbnailUrl,
        content,
        order,
        isActive,
      ];
}
