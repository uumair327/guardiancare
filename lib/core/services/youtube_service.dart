import 'dart:convert';
import 'package:guardiancare/core/core.dart';
import 'package:http/http.dart' as http;

class YoutubeService {
  final String apiKey = kYoutubeApiKey;

  Future<Map<String, dynamic>?> fetchVideo(String term) async {
    if (term.isEmpty || term[0] == '-') return null;

    final formattedTerm = term.startsWith('-') ? term.substring(1) : term;
    final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?part=snippet&q=$formattedTerm&maxResults=1&key=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['items']?.first;
    } else {
      print('Failed to fetch data for term: $formattedTerm');
      return null;
    }
  }
}
