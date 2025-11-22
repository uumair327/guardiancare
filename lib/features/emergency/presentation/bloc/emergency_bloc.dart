import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/emergency/domain/usecases/get_contacts_by_category.dart';
import 'package:guardiancare/features/emergency/domain/usecases/get_emergency_contacts.dart';
import 'package:guardiancare/features/emergency/domain/usecases/make_emergency_call.dart';
import 'package:guardiancare/features/emergency/presentation/bloc/emergency_event.dart';
import 'package:guardiancare/features/emergency/presentation/bloc/emergency_state.dart';

/// BLoC for managing emergency state
class EmergencyBloc extends Bloc<EmergencyEvent, EmergencyState> {
  final GetEmergencyContacts getEmergencyContacts;
  final GetContactsByCategory getContactsByCategory;
  final MakeEmergencyCall makeEmergencyCall;

  EmergencyBloc({
    required this.getEmergencyContacts,
    required this.getContactsByCategory,
    required this.makeEmergencyCall,
  }) : super(EmergencyInitial()) {
    on<LoadEmergencyContacts>(_onLoadEmergencyContacts);
    on<LoadContactsByCategory>(_onLoadContactsByCategory);
    on<MakeCallRequested>(_onMakeCallRequested);
  }

  Future<void> _onLoadEmergencyContacts(
    LoadEmergencyContacts event,
    Emitter<EmergencyState> emit,
  ) async {
    emit(EmergencyLoading());

    final result = await getEmergencyContacts(NoParams());

    result.fold(
      (failure) => emit(EmergencyError(failure.message)),
      (contacts) => emit(EmergencyContactsLoaded(contacts)),
    );
  }

  Future<void> _onLoadContactsByCategory(
    LoadContactsByCategory event,
    Emitter<EmergencyState> emit,
  ) async {
    emit(EmergencyLoading());

    final result = await getContactsByCategory(event.category);

    result.fold(
      (failure) => emit(EmergencyError(failure.message)),
      (contacts) => emit(EmergencyContactsLoaded(contacts)),
    );
  }

  Future<void> _onMakeCallRequested(
    MakeCallRequested event,
    Emitter<EmergencyState> emit,
  ) async {
    final currentState = state;
    emit(EmergencyCallInProgress());

    final result = await makeEmergencyCall(event.phoneNumber);

    result.fold(
      (failure) {
        emit(EmergencyError(failure.message));
        // Restore previous state after showing error
        if (currentState is EmergencyContactsLoaded) {
          emit(currentState);
        }
      },
      (_) {
        emit(EmergencyCallCompleted());
        // Restore previous state after call
        if (currentState is EmergencyContactsLoaded) {
          emit(currentState);
        }
      },
    );
  }
}
