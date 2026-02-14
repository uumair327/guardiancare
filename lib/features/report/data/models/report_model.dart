import 'package:guardiancare/features/report/domain/entities/report_entity.dart';

/// Report model extending ReportEntity with JSON serialization
class ReportModel extends ReportEntity {
  const ReportModel({
    required super.caseName,
    required super.questions,
    required super.answers,
    super.savedAt,
    super.isDirty,
  });

  /// Create ReportModel from ReportEntity
  factory ReportModel.fromEntity(ReportEntity entity) {
    return ReportModel(
      caseName: entity.caseName,
      questions: entity.questions,
      answers: entity.answers,
      savedAt: entity.savedAt,
      isDirty: entity.isDirty,
    );
  }

  /// Create ReportModel from JSON
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    final checkboxStates = json['checkboxStates'] as Map<String, dynamic>? ?? {};
    final answers = <int, bool>{};

    checkboxStates.forEach((key, value) {
      final index = int.tryParse(key);
      if (index != null && value is bool) {
        answers[index] = value;
      }
    });

    return ReportModel(
      caseName: json['caseName'] as String? ?? '',
      questions: const [], // Questions not stored in JSON, passed separately
      answers: answers,
      savedAt: json['savedAt'] != null
          ? DateTime.tryParse(json['savedAt'] as String)
          : null,
      isDirty: json['isDirty'] as bool? ?? false,
    );
  }

  /// Convert ReportModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'caseName': caseName,
      'checkboxStates':
          answers.map((key, value) => MapEntry(key.toString(), value)),
      'isDirty': isDirty,
      'selectedCount': selectedCount,
      'savedAt': savedAt?.toIso8601String(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  ReportModel copyWith({
    String? caseName,
    List<String>? questions,
    Map<int, bool>? answers,
    DateTime? savedAt,
    bool? isDirty,
  }) {
    return ReportModel(
      caseName: caseName ?? this.caseName,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      savedAt: savedAt ?? this.savedAt,
      isDirty: isDirty ?? this.isDirty,
    );
  }
}
