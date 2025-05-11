import 'package:flutter/foundation.dart';

abstract class BaseModel {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BaseModel({
    required this.id,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseModel &&
        other.id == id &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => id.hashCode ^ createdAt.hashCode ^ updatedAt.hashCode;

  @override
  String toString() {
    return 'BaseModel(id: $id, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
