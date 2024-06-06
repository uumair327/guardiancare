import 'dart:convert';

import 'package:http/http.dart' as http;

class HomeController {
  static Future<List<Map<String, dynamic>>> fetchVideoData() async {
    // Replace 'apiEndpoint' with the actual URL of your API endpoint
    const String apiUrl = '';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Parse the JSON response
        final List<dynamic> responseData = json.decode(response.body);

        // Map the response data to the required format
        List<Map<String, dynamic>> videoData = responseData.map((video) {
          return {
            'type': video['type'], // "image" or "video"
            'imageUrl': video['imageUrl'],
            'link': video['link'],
            'thumbnailUrl': video['thumbnailUrl'], // For videos
          };
        }).toList();

        return videoData;
      } else {
        // Handle API error
        throw Exception('Failed to load video data');
      }
    } catch (e) {
      // Handle network error
      throw Exception('Network error: $e');
    }
  }
}
