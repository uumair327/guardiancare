import 'package:equatable/equatable.dart';

/// Report entity representing an incident report
class ReportEntity extends Equatable {

  const ReportEntity({
    required this.caseName,
    required this.questions,
    required this.answers,
    this.savedAt,
    this.isDirty = false,
  });
  final String caseName;
  final List<String> questions;
  final Map<int, bool> answers;
  final DateTime? savedAt;
  final bool isDirty;

  @override
  List<Object?> get props => [caseName, questions, answers, savedAt, isDirty];

  /// Get the number of selected items
  int get selectedCount => answers.values.where((selected) => selected).length;

  /// Get the total number of questions
  int get totalCount => questions.length;

  /// Check if any items are selected
  bool get hasSelections => selectedCount > 0;

  /// Get list of selected question indices
  List<int> get selectedIndices {
    return answers.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get list of selected questions
  List<String> get selectedQuestions {
    return selectedIndices
        .where((index) => index < questions.length)
        .map((index) => questions[index])
        .toList();
  }

  /// Get completion percentage
  double get completionPercentage {
    if (totalCount == 0) return 0;
    return selectedCount / totalCount;
  }

  bool get isValid => caseName.isNotEmpty && questions.isNotEmpty;
}
