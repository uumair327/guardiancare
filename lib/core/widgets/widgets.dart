export 'app_restart_widget.dart';
export 'bottom_nav.dart';
export 'content_card.dart';
export 'language_selector_dialog.dart';
export 'parental_lock_overlay.dart';
export 'parental_verification_dialog.dart';
export 'pdf_viewer_page.dart';
export 'sufasec_content.dart';
export 'theme_toggle.dart';

// Conditional export for web compatibility
// youtube_player_flutter doesn't support web, so we use iframe-based implementation
export 'video_player_page.dart'
    if (dart.library.html) 'video_player_page_web.dart';

// Conditional export for web compatibility
// webview_flutter doesn't support web, so we use iframe-based implementation
export 'web_view_page.dart' if (dart.library.html) 'web_view_page_web.dart';
