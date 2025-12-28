// Conditional export for web compatibility
// youtube_player_flutter doesn't support web, so we use iframe-based implementation
export 'video_player_page.dart'
    if (dart.library.html) 'video_player_page_web.dart';
