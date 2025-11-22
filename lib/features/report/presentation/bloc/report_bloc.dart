import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/report/domain/entities/report_entity.dart';
import 'package:guardiancare/features/report/domain/usecases/create_report.dart';
import 'package:guardiancare/features/report/domain/usecases/delete_report.dart';
import 'package:guardiancare/features/report/domain/usecases/get_saved_reports.dart';
import 'package:guardiancare/features/report/domain/usecases/load_report.dart';
import 'package:guardiancare/features/report/domain/usecases/save_report.dart';
import 'package:guardiancare/features/report/presentation/bloc/report_event.dart';
import 'package:guardiancare/features/report/presentation/bloc/report_state.dart';

/// BLoC for managing report state with Clean Architecture
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final CreateReport createReport;
  final LoadReport loadReport;
  final SaveReport saveReport;
  final DeleteReport deleteReport;
  final GetSavedReports getSavedReports;

  ReportBloc({
    required this.createReport,
    required this.loadReport,
    required this.saveReport,
    required this.deleteReport,
    required this.getSavedReports,
  }) : super(const ReportInitial()) {
    on<CreateReportRequested>(_onCreateReport);
    on<LoadReportRequested>(_onLoadReport);
    on<UpdateAnswerRequested>(_onUpdateAnswer);
    on<SaveReportRequested>(_onSaveReport);
    on<DeleteReportRequested>(_onDeleteReport);
    on<LoadSavedReportsRequested>(_onLoadSavedReports);
    on<ClearReportRequested>(_onClearReport);
  }

  Future<void> _onCreateReport(
    CreateReportRequested event,
    Emitter<ReportState> emit,
  ) async {
    final result = await createReport(
      CreateReportParams(
        caseName: event.caseName,
        questions: event.questions,
      ),
    );

    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (report) => emit(ReportLoaded(report)),
    );
  }

  Future<void> _onLoadReport(
    LoadReportRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(const ReportLoading());

    final result = await loadReport(event.caseName);

    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (report) => emit(ReportLoaded(report)),
    );
  }

  void _onUpdateAnswer(
    UpdateAnswerRequested event,
    Emitter<ReportState> emit,
  ) {
    if (state is ReportLoaded) {
      final currentState = state as ReportLoaded;
      final currentReport = currentState.report;

      // Create updated answers map
      final updatedAnswers = Map<int, bool>.from(currentReport.answers);
      updatedAnswers[event.questionIndex] = event.isChecked;

      // Create updated report
      final updatedReport = ReportEntity(
        caseName: currentReport.caseName,
        questions: currentReport.questions,
        answers: updatedAnswers,
        savedAt: currentReport.savedAt,
        isDirty: true,
      );

      emit(ReportLoaded(updatedReport));
    }
  }

  Future<void> _onSaveReport(
    SaveReportRequested event,
    Emitter<ReportState> emit,
  ) async {
    if (state is ReportLoaded) {
      final currentState = state as ReportLoaded;
      emit(ReportSaving(currentState.report));

      final result = await saveReport(currentState.report);

      result.fold(
        (failure) => emit(ReportError(failure.message)),
        (_) {
          // Create saved report with updated timestamp
          final savedReport = ReportEntity(
            caseName: currentState.report.caseName,
            questions: currentState.report.questions,
            answers: currentState.report.answers,
            savedAt: DateTime.now(),
            isDirty: false,
          );
          emit(ReportSaved(savedReport));
        },
      );
    }
  }

  Future<void> _onDeleteReport(
    DeleteReportRequested event,
    Emitter<ReportState> emit,
  ) async {
    final result = await deleteReport(event.caseName);

    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (_) => emit(const ReportInitial()),
    );
  }

  Future<void> _onLoadSavedReports(
    LoadSavedReportsRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(const ReportLoading());

    final result = await getSavedReports(NoParams());

    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (reports) => emit(SavedReportsLoaded(reports)),
    );
  }

  void _onClearReport(
    ClearReportRequested event,
    Emitter<ReportState> emit,
  ) {
    emit(const ReportInitial());
  }
}
