/// Feature Flag Domain Entity
///
/// Mirrors the Firestore `feature_flags` collection document schema
/// defined in the CIF Dashboard.
///
/// The [key] must match the FeatureFlagKey strings used in the dashboard.
class FeatureFlagEntity {
  const FeatureFlagEntity({
    required this.key,
    required this.name,
    required this.description,
    required this.enabled,
    required this.category,
    this.lastModifiedBy,
    this.lastModifiedAt,
  });

  /// Firestore document ID — e.g. 'feature.forum', 'feature.quiz'
  final String key;

  /// Human-readable name shown in the dashboard
  final String name;

  /// What enabling/disabling this flag controls
  final String description;

  /// Whether the feature is currently active
  final bool enabled;

  /// Category: 'app' | 'dashboard' | 'experimental'
  final String category;

  /// Email/ID of the admin who last changed this
  final String? lastModifiedBy;

  /// When it was last changed
  final DateTime? lastModifiedAt;

  FeatureFlagEntity copyWith({bool? enabled}) {
    return FeatureFlagEntity(
      key: key,
      name: name,
      description: description,
      enabled: enabled ?? this.enabled,
      category: category,
      lastModifiedBy: lastModifiedBy,
      lastModifiedAt: lastModifiedAt,
    );
  }

  @override
  String toString() => 'FeatureFlagEntity(key: $key, enabled: $enabled)';
}
