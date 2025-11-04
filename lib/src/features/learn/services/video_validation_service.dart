import '../models/models.dart';

class VideoValidationService {
  static bool isValidYouTubeUrl(String url) {
    if (url.isEmpty) return false;
    
    final youtubeRegex = RegExp(
      r'^https?:\/\/(www\.)?(youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)[a-zA-Z0-9_-]+',
      caseSensitive: false,
    );
    
    return youtubeRegex.hasMatch(url);
  }

  static bool isValidHttpUrl(String url) {
    if (url.isEmpty) return false;
    
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  static String? extractYouTubeVideoId(String url) {
    if (!isValidYouTubeUrl(url)) return null;
    
    final regexes = [
      RegExp(r'youtube\.com\/watch\?v=([a-zA-Z0-9_-]+)'),
      RegExp(r'youtu\.be\/([a-zA-Z0-9_-]+)'),
      RegExp(r'youtube\.com\/embed\/([a-zA-Z0-9_-]+)'),
    ];
    
    for (final regex in regexes) {
      final match = regex.firstMatch(url);
      if (match != null) {
        return match.group(1);
      }
    }
    
    return null;
  }

  static List<VideoModel> filterValidVideos(List<VideoModel> videos) {
    return videos.where((video) {
      if (!video.isValid) return false;
      
      // Additional validation for video URLs
      if (!isValidHttpUrl(video.videoUrl)) return false;
      
      // Additional validation for thumbnail URLs
      if (!isValidHttpUrl(video.thumbnailUrl)) return false;
      
      return true;
    }).toList();
  }

  static List<CategoryModel> filterValidCategories(List<CategoryModel> categories) {
    return categories.where((category) {
      if (!category.isValid) return false;
      
      // Additional validation for thumbnail URLs
      if (!isValidHttpUrl(category.thumbnail)) return false;
      
      return true;
    }).toList();
  }
}