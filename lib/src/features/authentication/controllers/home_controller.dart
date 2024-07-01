import 'package:http/http.dart' as http;

class HomeController {
  static Future<List<Map<String, dynamic>>> fetchVideoData() async {
    List<Map<String, dynamic>> videoData = [];
    final videoUrls = [
      'https://www.youtube.com/watch?v=d5dCN66PokQ',
      'https://www.youtube.com/watch?v=_MXD-eL4z_M',
      'https://www.youtube.com/watch?v=sehKCzxIblQ',
      'https://www.youtube.com/watch?v=qRLqkqWBJPE',
      'https://www.youtube.com/watch?v=3SzazN2OrsQ',
    ];

    for (final videoUrl in videoUrls) {
      final response = await http.get(Uri.parse(videoUrl));
      if (response.statusCode == 200) {
        final videoTitle = _extractVideoTitle(response.body);
        final thumbnailUrl = await _getThumbnailUrl(videoUrl);
        videoData.add({
          'url': videoUrl,
          'title': videoTitle,
          'thumbnailUrl': thumbnailUrl
        });
      } else {
        print('Failed to fetch video title for $videoUrl');
      }
    }
    return videoData;
  }

  static String _extractVideoTitle(String html) {
    final regExp =
        RegExp(r'<title>(?:\S+\s*\|)?\s*(?<title>[\S\s]+?) - YouTube</title>');
    final match = regExp.firstMatch(html);
    return match?.namedGroup('title') ?? '';
  }

  static Future<String> _getThumbnailUrl(String videoUrl) async {
    final videoId = _extractVideoId(videoUrl);
    return 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
  }

  static String _extractVideoId(String url) {
    final regExp = RegExp(
        r"(?:https:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/|www\.youtube\.com\/\S*?[?&]v=)?([a-zA-Z0-9_-]{11})");
    final match = regExp.firstMatch(url);
    return match?.group(1) ?? '';
  }
}
