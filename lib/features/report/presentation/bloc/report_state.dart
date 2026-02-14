import 'package:equatable/equatable.dart';
import 'package:guardiancare/features/report/domain/entities/report_entity.dart';

/// Base class for report states
abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ReportInitial extends ReportState {
  const ReportInitial();
}

/// Loading state
class ReportLoading extends ReportState {
  const ReportLoading();
}

/// Report loaded successfully
class ReportLoaded extends ReportState {

  const ReportLoaded(this.report);
  final ReportEntity report;

  @override
  List<Object?> get props => [report];
}

/// Report saving state
class ReportSaving extends ReportState {

  const ReportSaving(this.report);
  final ReportEntity report;

  @override
  List<Object?> get props => [report];
}

/// Report saved successfully
class ReportSaved extends ReportState {

  const ReportSaved(this.report);
  final ReportEntity report;

  @override
  List<Object?> get props => [report];
}

/// Saved reports loaded
class SavedReportsLoaded extends ReportState {

  const SavedReportsLoaded(this.savedReports);
  final List<String> savedReports;

  @override
  List<Object?> get props => [savedReports];
}

/// Error state
class ReportError extends ReportState {

  const ReportError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
