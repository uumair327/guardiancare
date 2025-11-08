import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/src/features/report/models/report_form_state.dart';
import 'package:guardiancare/src/features/report/services/report_persistence_service.dart';

// Events
abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class CreateReport extends ReportEvent {
  final String caseName;
  final List<String> questions;

  const CreateReport(this.caseName, this.questions);

  @override
  List<Object?> get props => [caseName, questions];
}

class LoadReport extends ReportEvent {
  final String caseName;

  const LoadReport(this.caseName);

  @override
  List<Object?> get props => [caseName];
}

class UpdateAnswer extends ReportEvent {
  final int questionIndex;
  final bool isChecked;

  const UpdateAnswer(this.questionIndex, this.isChecked);

  @override
  List<Object?> get props => [questionIndex, isChecked];
}

class SaveReport extends ReportEvent {
  const SaveReport();
}

class DeleteReport extends ReportEvent {
  final String caseName;

  const DeleteReport(this.caseName);

  @override
  List<Object?> get props => [caseName];
}

class LoadSavedReports extends ReportEvent {
  const LoadSavedReports();
}

class ClearReport extends ReportEvent {
  const ClearReport();
}

// State
abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {
  const ReportInitial();
}

class ReportLoading extends ReportState {
  const ReportLoading();
}

class ReportLoaded extends ReportState {
  final ReportFormState formState;

  const ReportLoaded(this.formState);

  @override
  List<Object?> get props => [formState];
}

class ReportSaving extends ReportState {
  final ReportFormState formState;

  const ReportSaving(this.formState);

  @override
  List<Object?> get props => [formState];
}

class ReportSaved extends ReportState {
  final ReportFormState formState;

  const ReportSaved(this.formState);

  @override
  List<Object?> get props => [formState];
}

class SavedReportsLoaded extends ReportState {
  final List<String> savedReports;

  const SavedReportsLoaded(this.savedReports);

  @override
  List<Object?> get props => [savedReports];
}

class ReportError extends ReportState {
  final String message;

  const ReportError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportPersistenceService _persistenceService = ReportPersistenceService.instance;

  ReportBloc() : super(const ReportInitial()) {
    on<CreateReport>(_onCreateReport);
    on<LoadReport>(_onLoadReport);
    on<UpdateAnswer>(_onUpdateAnswer);
    on<SaveReport>(_onSaveReport);
    on<DeleteReport>(_onDeleteReport);
    on<LoadSavedReports>(_onLoadSavedReports);
    on<ClearReport>(_onClearReport);
  }

  void _onCreateReport(CreateReport event, Emitter<ReportState> emit) {
    final formState = ReportFormState(
      caseName: event.caseName,
      questions: event.questions,
    );
    emit(ReportLoaded(formState));
  }

  Future<void> _onLoadReport(LoadReport event, Emitter<ReportState> emit) async {
    emit(const ReportLoading());
    try {
      final savedData = await _persistenceService.loadFormState(event.caseName);
      
      if (savedData != null) {
        final formState = ReportFormState.fromMap(savedData);
        emit(ReportLoaded(formState));
      } else {
        emit(ReportError('Report not found: ${event.caseName}'));
      }
    } catch (e) {
      emit(ReportError('Failed to load report: ${e.toString()}'));
    }
  }

  void _onUpdateAnswer(UpdateAnswer event, Emitter<ReportState> emit) {
    if (state is ReportLoaded) {
      final currentState = state as ReportLoaded;
      currentState.formState.updateAnswer(event.questionIndex, event.isChecked);
      emit(ReportLoaded(currentState.formState));
    }
  }

  Future<void> _onSaveReport(SaveReport event, Emitter<ReportState> emit) async {
    if (state is ReportLoaded) {
      final currentState = state as ReportLoaded;
      emit(ReportSaving(currentState.formState));
      
      try {
        final success = await _persistenceService.saveFormState(currentState.formState);
        
        if (success) {
          emit(ReportSaved(currentState.formState));
        } else {
          emit(const ReportError('Failed to save report'));
        }
      } catch (e) {
        emit(ReportError('Failed to save report: ${e.toString()}'));
      }
    }
  }

  Future<void> _onDeleteReport(DeleteReport event, Emitter<ReportState> emit) async {
    try {
      final success = await _persistenceService.deleteFormState(event.caseName);
      
      if (success) {
        emit(const ReportInitial());
      } else {
        emit(const ReportError('Failed to delete report'));
      }
    } catch (e) {
      emit(ReportError('Failed to delete report: ${e.toString()}'));
    }
  }

  Future<void> _onLoadSavedReports(LoadSavedReports event, Emitter<ReportState> emit) async {
    emit(const ReportLoading());
    try {
      final savedReports = await _persistenceService.getSavedFormNames();
      emit(SavedReportsLoaded(savedReports));
    } catch (e) {
      emit(ReportError('Failed to load saved reports: ${e.toString()}'));
    }
  }

  void _onClearReport(ClearReport event, Emitter<ReportState> emit) {
    emit(const ReportInitial());
  }
}
