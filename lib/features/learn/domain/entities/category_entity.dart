import 'package:equatable/equatable.dart';

/// Category entity representing a learning category
class CategoryEntity extends Equatable {
  final String name;
  final String thumbnail;

  const CategoryEntity({
    required this.name,
    required this.thumbnail,
  });

  @override
  List<Object> get props => [name, thumbnail];

  bool get isValid => name.isNotEmpty && thumbnail.isNotEmpty;
}
