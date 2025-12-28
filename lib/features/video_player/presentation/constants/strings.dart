/// Video player feature-specific strings for the GuardianCare application.
///
/// This class provides string constants specific to the Video Player feature,
/// following Clean Architecture principles by keeping feature-specific
/// strings within the feature module.
///
/// ## Purpose
/// - Centralizes all video player-related text constants
/// - Keeps video player strings isolated from other features
/// - Simplifies video player UI development
/// - Supports future localization efforts
///
/// ## Categories
/// - **Page Titles**: Video player page titles
/// - **Labels**: Playback and progress labels
/// - **Action Labels**: Player control labels
/// - **Speed Labels**: Playback speed labels
/// - **Error States**: Video player error messages
/// - **Info Messages**: Player hints and instructions
///
/// ## Usage Example
/// ```dart
/// import 'package:guardiancare/features/video_player/presentation/constants/strings.dart';
///
/// // Page title
/// AppBar(title: Text(VideoPlayerStrings.pageTitle));
///
/// // Playback speed label
/// Text(VideoPlayerStrings.playbackSpeed);
///
/// // Speed display with template method
/// Text(VideoPlayerStrings.speedDisplay(1.5)); // "1.5x"
///
/// // Watched duration
/// Text(VideoPlayerStrings.watched('5:30')); // "5:30 watched"
///
/// // Error message
/// Text(VideoPlayerStrings.invalidVideoUrl);
/// ```
///
/// ## Best Practices
/// - Use VideoPlayerStrings only within the video player feature
/// - For common UI text, use [UIStrings] instead
/// - For feedback messages, use [FeedbackStrings]
/// - Keep video player-specific text in this class
///
/// See also:
/// - [UIStrings] for common UI text
/// - [FeedbackStrings] for SnackBar/toast messages
/// - [ErrorStrings] for error messages
class VideoPlayerStrings {
  VideoPlayerStrings._();

  // ==================== Page Titles ====================
  static const String pageTitle = 'Video Player';
  static const String videoComplete = 'Video Complete!';

  // ==================== Labels ====================
  static const String playbackSpeed = 'Playback Speed';
  static const String watchProgress = 'Watch Progress';
  static const String webPlayer = 'Web Player';
  static const String youtubeVideo = 'YouTube Video';

  // ==================== Action Labels ====================
  static const String restart = 'Restart';
  static const String speed = 'Speed';
  static const String fullscreen = 'Fullscreen';
  static const String replay = 'Replay';

  // ==================== Speed Labels ====================
  static const String normal = 'Normal';

  // ==================== Error States ====================
  static const String invalidVideoUrl = 'Invalid Video URL';
  static const String invalidVideoUrlDescription =
      'The video link appears to be invalid.\nPlease check and try again.';
  static const String videoPlaybackError = 'Video playback error';

  // ==================== Info Messages ====================
  static const String watchAgainPrompt = 'Would you like to watch it again?';
  static const String usingYoutubeEmbedded = 'Using YouTube embedded player';
  static const String usePlayerControls = 'Use player controls';
  static const String returnToPreviousPage = 'Return to previous page';
  static const String webPlayerInstructions =
      'Use the YouTube player controls to play, pause, and navigate through the video.';

  // ==================== Template Methods ====================
  /// Creates a watched duration string
  static String watched(String duration) => '$duration watched';

  /// Creates a speed display string
  static String speedDisplay(double speed) =>
      speed == 1.0 ? '1x' : '${speed}x';
}
