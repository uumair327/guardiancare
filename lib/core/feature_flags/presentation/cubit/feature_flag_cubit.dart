import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/feature_flags/domain/entities/feature_flag_entity.dart';
import 'package:guardiancare/core/feature_flags/domain/entities/feature_flag_keys.dart';
import 'package:guardiancare/core/feature_flags/domain/repositories/i_feature_flag_repository.dart';
import 'package:guardiancare/core/util/logger.dart';

// ─── State ────────────────────────────────────────────────────────────────────

/// Represents the current state of feature flags in the app.
sealed class FeatureFlagState {
  const FeatureFlagState();
}

/// Flags are still being fetched for the first time.
final class FeatureFlagLoading extends FeatureFlagState {
  const FeatureFlagLoading();
}

/// Flags loaded successfully.
final class FeatureFlagLoaded extends FeatureFlagState {
  const FeatureFlagLoaded(this.flags);
  final List<FeatureFlagEntity> flags;

  /// Returns true if the given flag key is enabled.
  /// Falls back to the declared default if the key is not yet in the list.
  bool isEnabled(String key) {
    final flag = flags.where((f) => f.key == key).firstOrNull;
    if (flag == null) {
      return FeatureFlagKeys.defaults[key] ?? true;
    }
    return flag.enabled;
  }
}

/// Failed to load flags — includes an error message.
final class FeatureFlagError extends FeatureFlagState {
  const FeatureFlagError(this.message);
  final String message;
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

/// Manages real-time feature flag state using a Firestore stream.
///
/// Automatically updates when an admin toggles a flag in the CIF Dashboard.
/// Uses BLoC Cubit for simplicity — no events needed, just streaming state.
class FeatureFlagCubit extends Cubit<FeatureFlagState> {
  FeatureFlagCubit({required IFeatureFlagRepository repository})
      : _repository = repository,
        super(const FeatureFlagLoading());

  final IFeatureFlagRepository _repository;
  StreamSubscription<List<FeatureFlagEntity>>? _subscription;

  /// Start listening to real-time flag updates from Firestore.
  void startListening() {
    _subscription?.cancel();
    _subscription = _repository.watchAll().listen(
      (flags) {
        Log.d('[FeatureFlagCubit] Updated: ${flags.length} flags');
        emit(FeatureFlagLoaded(flags));
      },
      onError: (Object error) {
        Log.e('[FeatureFlagCubit] Error: $error');
        emit(FeatureFlagError(error.toString()));
      },
    );
  }

  /// Convenience: check if a flag is enabled without subscribing to full state.
  /// Returns `true` (safe default) if flags are still loading.
  bool isEnabled(String key) {
    final s = state;
    if (s is FeatureFlagLoaded) return s.isEnabled(key);
    // While loading or on error, default to enabled (fail-open for UX)
    return FeatureFlagKeys.defaults[key] ?? true;
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
