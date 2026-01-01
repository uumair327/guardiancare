import 'package:equatable/equatable.dart';

/// User statistics entity representing quiz, video, and badge progress.
/// 
/// This entity aggregates user activity data from multiple sources
/// to provide a unified view of user achievements and progress.
class UserStatsEntity extends Equatable {
  /// Total number of quizzes completed by the user
  final int quizzesCompleted;
  
  /// Average score across all completed quizzes (0-100)
  final double averageQuizScore;
  
  /// Best quiz score achieved (0-100)
  final double bestQuizScore;
  
  /// Total number of videos watched (started)
  final int videosWatched;
  
  /// Number of videos completed (90%+ watched)
  final int videosCompleted;
  
  /// Total watch time in seconds
  final int totalWatchTimeSeconds;
  
  /// Number of badges earned
  final int badgesEarned;
  
  /// List of earned badge identifiers
  final List<BadgeEntity> badges;

  const UserStatsEntity({
    this.quizzesCompleted = 0,
    this.averageQuizScore = 0.0,
    this.bestQuizScore = 0.0,
    this.videosWatched = 0,
    this.videosCompleted = 0,
    this.totalWatchTimeSeconds = 0,
    this.badgesEarned = 0,
    this.badges = const [],
  });

  /// Empty stats for new users or error states
  static const empty = UserStatsEntity();

  @override
  List<Object?> get props => [
        quizzesCompleted,
        averageQuizScore,
        bestQuizScore,
        videosWatched,
        videosCompleted,
        totalWatchTimeSeconds,
        badgesEarned,
        badges,
      ];
}

/// Badge entity representing an achievement the user has earned.
/// 
/// Badges are awarded based on user activity milestones like
/// completing quizzes, watching videos, or achieving high scores.
class BadgeEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final BadgeType type;
  final DateTime? earnedAt;

  const BadgeEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.earnedAt,
  });

  @override
  List<Object?> get props => [id, name, description, type, earnedAt];
}

/// Types of badges that can be earned
enum BadgeType {
  /// Quiz-related achievements
  quiz,
  /// Video-related achievements
  video,
  /// Learning streak achievements
  streak,
  /// Special achievements
  special,
}
