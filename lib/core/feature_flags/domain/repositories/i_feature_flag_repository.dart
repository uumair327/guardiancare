import 'package:guardiancare/core/feature_flags/domain/entities/feature_flag_entity.dart';

/// Repository interface for feature flags.
///
/// Follows Dependency Inversion Principle — domain does not depend on Firestore.
/// Both FirebaseFeatureFlagRepository and any future Supabase implementation
/// implement this interface.
abstract interface class IFeatureFlagRepository {
  /// Returns a live stream of all feature flags.
  /// Emits a new list whenever any flag is toggled in the dashboard.
  Stream<List<FeatureFlagEntity>> watchAll();

  /// Fetches all flags once (non-streaming).
  Future<List<FeatureFlagEntity>> getAll();
}
