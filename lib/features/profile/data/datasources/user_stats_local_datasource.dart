import 'package:guardiancare/core/database/daos/quiz_dao.dart';
import 'package:guardiancare/core/database/daos/video_dao.dart';
import 'package:guardiancare/features/profile/domain/entities/user_stats_entity.dart';

/// Local data source for user statistics.
/// 
/// Aggregates data from QuizDao and VideoDao to provide
/// unified user statistics. Uses local SQLite database.
abstract class UserStatsLocalDataSource {
  /// Fetches user statistics from local database
  Future<UserStatsEntity> getUserStats(String userId);
  
  /// Calculates badges based on user activity
  Future<List<BadgeEntity>> calculateBadges(String userId);
}

/// Implementation of [UserStatsLocalDataSource] using DAOs.
/// 
/// Follows Single Responsibility by delegating database operations
/// to specialized DAOs (QuizDao, VideoDao).
class UserStatsLocalDataSourceImpl implements UserStatsLocalDataSource {
  final QuizDao quizDao;
  final VideoDao videoDao;

  UserStatsLocalDataSourceImpl({
    required this.quizDao,
    required this.videoDao,
  });

  @override
  Future<UserStatsEntity> getUserStats(String userId) async {
    // Fetch quiz statistics
    final quizStats = await quizDao.getQuizStatistics(userId);
    
    // Fetch video statistics
    final videoStats = await videoDao.getWatchStatistics(userId);
    
    // Calculate badges
    final badges = await calculateBadges(userId);
    
    return UserStatsEntity(
      quizzesCompleted: (quizStats['total_quizzes'] as int?) ?? 0,
      averageQuizScore: (quizStats['average_score'] as double?) ?? 0.0,
      bestQuizScore: (quizStats['best_score'] as double?) ?? 0.0,
      videosWatched: (videoStats['total_videos'] as int?) ?? 0,
      videosCompleted: (videoStats['completed_videos'] as int?) ?? 0,
      totalWatchTimeSeconds: (videoStats['total_watch_time'] as int?) ?? 0,
      badgesEarned: badges.length,
      badges: badges,
    );
  }

  @override
  Future<List<BadgeEntity>> calculateBadges(String userId) async {
    final badges = <BadgeEntity>[];
    
    // Fetch stats for badge calculation
    final quizStats = await quizDao.getQuizStatistics(userId);
    final videoStats = await videoDao.getWatchStatistics(userId);
    
    final quizzesCompleted = (quizStats['total_quizzes'] as int?) ?? 0;
    final bestScore = (quizStats['best_score'] as double?) ?? 0.0;
    final videosCompleted = (videoStats['completed_videos'] as int?) ?? 0;
    
    // Quiz badges
    if (quizzesCompleted >= 1) {
      badges.add(const BadgeEntity(
        id: 'first_quiz',
        name: 'First Steps',
        description: 'Completed your first quiz',
        type: BadgeType.quiz,
      ));
    }
    
    if (quizzesCompleted >= 5) {
      badges.add(const BadgeEntity(
        id: 'quiz_enthusiast',
        name: 'Quiz Enthusiast',
        description: 'Completed 5 quizzes',
        type: BadgeType.quiz,
      ));
    }
    
    if (quizzesCompleted >= 10) {
      badges.add(const BadgeEntity(
        id: 'quiz_master',
        name: 'Quiz Master',
        description: 'Completed 10 quizzes',
        type: BadgeType.quiz,
      ));
    }
    
    if (bestScore >= 100.0) {
      badges.add(const BadgeEntity(
        id: 'perfect_score',
        name: 'Perfect Score',
        description: 'Achieved 100% on a quiz',
        type: BadgeType.quiz,
      ));
    }
    
    if (bestScore >= 90.0 && bestScore < 100.0) {
      badges.add(const BadgeEntity(
        id: 'high_achiever',
        name: 'High Achiever',
        description: 'Scored 90% or higher on a quiz',
        type: BadgeType.quiz,
      ));
    }
    
    // Video badges
    if (videosCompleted >= 1) {
      badges.add(const BadgeEntity(
        id: 'first_video',
        name: 'Video Starter',
        description: 'Watched your first video',
        type: BadgeType.video,
      ));
    }
    
    if (videosCompleted >= 5) {
      badges.add(const BadgeEntity(
        id: 'video_learner',
        name: 'Video Learner',
        description: 'Completed 5 videos',
        type: BadgeType.video,
      ));
    }
    
    if (videosCompleted >= 10) {
      badges.add(const BadgeEntity(
        id: 'video_expert',
        name: 'Video Expert',
        description: 'Completed 10 videos',
        type: BadgeType.video,
      ));
    }
    
    // Combined achievement badges
    if (quizzesCompleted >= 3 && videosCompleted >= 3) {
      badges.add(const BadgeEntity(
        id: 'well_rounded',
        name: 'Well Rounded',
        description: 'Completed 3 quizzes and 3 videos',
        type: BadgeType.special,
      ));
    }
    
    if (quizzesCompleted >= 10 && videosCompleted >= 10) {
      badges.add(const BadgeEntity(
        id: 'safety_champion',
        name: 'Safety Champion',
        description: 'Completed 10 quizzes and 10 videos',
        type: BadgeType.special,
      ));
    }
    
    return badges;
  }
}
