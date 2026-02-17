import 'package:equatable/equatable.dart';

/// Base class for report events
abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

/// Event to create a new report
class CreateReportRequested extends ReportEvent {
  const CreateReportRequested(this.caseName, this.questions);
  final String caseName;
  final List<String> questions;

  @override
  List<Object?> get props => [caseName, questions];
}

/// Event to load a saved report
class LoadReportRequested extends ReportEvent {
  const LoadReportRequested(this.caseName);
  final String caseName;

  @override
  List<Object?> get props => [caseName];
}

/// Event to update an answer
class UpdateAnswerRequested extends ReportEvent {
  const UpdateAnswerRequested({
    required this.questionIndex,
    required this.isChecked,
  });
  final int questionIndex;
  final bool isChecked;

  @override
  List<Object?> get props => [questionIndex, isChecked];
}

/// Event to save the report
class SaveReportRequested extends ReportEvent {
  const SaveReportRequested();
}

/// Event to delete a report
class DeleteReportRequested extends ReportEvent {
  const DeleteReportRequested(this.caseName);
  final String caseName;

  @override
  List<Object?> get props => [caseName];
}

/// Event to load all saved reports
class LoadSavedReportsRequested extends ReportEvent {
  const LoadSavedReportsRequested();
}

/// Event to clear the current report
class ClearReportRequested extends ReportEvent {
  const ClearReportRequested();
}
