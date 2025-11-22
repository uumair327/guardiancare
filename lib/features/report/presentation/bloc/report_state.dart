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
  final ReportEntity report;

  const ReportLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

/// Report saving state
class ReportSaving extends ReportState {
  final ReportEntity report;

  const ReportSaving(this.report);

  @override
  List<Object?> get props => [report];
}

/// Report saved successfully
class ReportSaved extends ReportState {
  final ReportEntity report;

  const ReportSaved(this.report);

  @override
  List<Object?> get props => [report];
}

/// Saved reports loaded
class SavedReportsLoaded extends ReportState {
  final List<String> savedReports;

  const SavedReportsLoaded(this.savedReports);

  @override
  List<Object?> get props => [savedReports];
}

/// Error state
class ReportError extends ReportState {
  final String message;

  const ReportError(this.message);

  @override
  List<Object?> get props => [message];
}
