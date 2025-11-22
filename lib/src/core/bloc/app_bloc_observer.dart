import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/src/core/logging/app_logger.dart';

/// Global BLoC observer for logging and debugging
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    AppLogger.debug('BLoC', '${bloc.runtimeType} created');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    AppLogger.bloc(
      bloc.runtimeType.toString(),
      event.toString(),
    );
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    AppLogger.state(
      bloc.runtimeType.toString(),
      '${change.currentState.runtimeType} → ${change.nextState.runtimeType}',
    );
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    AppLogger.debug(
      'BLoC',
      '${bloc.runtimeType}: ${transition.event.runtimeType} → ${transition.nextState.runtimeType}',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    AppLogger.error(
      bloc.runtimeType.toString(),
      'BLoC Error: ${error.toString()}',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    AppLogger.debug('BLoC', '${bloc.runtimeType} closed');
  }
}
