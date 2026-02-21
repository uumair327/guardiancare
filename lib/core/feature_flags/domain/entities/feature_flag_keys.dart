/// All feature flag keys used across the GuardianCare app.
///
/// These MUST match the FeatureFlagKey strings defined in the CIF Dashboard:
///   src/core/feature-flags/domain/entities/FeatureFlag.ts
///
/// Adding a new flag:
///   1. Add it here as a constant
///   2. Add it to the CIF Dashboard's FeatureFlagKey union
///   3. Add its definition to APP_FEATURE_FLAGS in the dashboard
///
/// Convention: 'feature.[snake_case_name]'
abstract final class FeatureFlagKeys {
  FeatureFlagKeys._();

  // ── App Features ──────────────────────────────────────────────────────────
  static const String carousel = 'feature.carousel';
  static const String homeImages = 'feature.home_images';
  static const String forum = 'feature.forum';
  static const String forumParent = 'feature.forum_parent';
  static const String forumChildren = 'feature.forum_children';
  static const String learn = 'feature.learn';
  static const String quizzes = 'feature.quizzes';
  static const String videos = 'feature.videos';
  static const String quizManager = 'feature.quiz_manager';

  // ── Dashboard Features ────────────────────────────────────────────────────
  static const String dashboardFeatureFlags = 'dashboard.feature_flags';
  static const String dashboardAnalytics = 'dashboard.analytics';

  /// All known keys — used for safe default fallback lookup.
  static const Set<String> all = {
    carousel,
    homeImages,
    forum,
    forumParent,
    forumChildren,
    learn,
    quizzes,
    videos,
    quizManager,
    dashboardFeatureFlags,
    dashboardAnalytics,
  };

  /// Default enabled state for each key (fallback when Firestore is unavailable).
  static const Map<String, bool> defaults = {
    carousel: true,
    homeImages: true,
    forum: true,
    forumParent: true,
    forumChildren: true,
    learn: true,
    quizzes: true,
    videos: true,
    quizManager: true,
    dashboardFeatureFlags: true,
    dashboardAnalytics: true,
  };
}
