import 'package:equatable/equatable.dart';

/// Base class for report events
abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

/// Event to create a new report
class CreateReportRequested extends ReportEvent {
  final String caseName;
  final List<String> questions;

  const CreateReportRequested(this.caseName, this.questions);

  @override
  List<Object?> get props => [caseName, questions];
}

/// Event to load a saved report
class LoadReportRequested extends ReportEvent {
  final String caseName;

  const LoadReportRequested(this.caseName);

  @override
  List<Object?> get props => [caseName];
}

/// Event to update an answer
class UpdateAnswerRequested extends ReportEvent {
  final int questionIndex;
  final bool isChecked;

  const UpdateAnswerRequested(this.questionIndex, this.isChecked);

  @override
  List<Object?> get props => [questionIndex, isChecked];
}

/// Event to save the report
class SaveReportRequested extends ReportEvent {
  const SaveReportRequested();
}

/// Event to delete a report
class DeleteReportRequested extends ReportEvent {
  final String caseName;

  const DeleteReportRequested(this.caseName);

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
