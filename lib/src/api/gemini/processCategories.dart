import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:guardiancare/src/api/youtube/fetchVideos.dart';
import 'package:guardiancare/src/constants/keys.dart';

Future<bool> processCategories(
    List<String> incorrectCategories, String category) async {
  try {
    Gemini.init(apiKey: kGeminiApiKey, enableDebugging: true);

    final gemini = Gemini.instance;

    final response = await gemini.text(
        "Summarize the subtopics $incorrectCategories under the main topic $category into a single search term for YouTube. The term should effectively encompass all subtopics and the main topic, consisting of 4-5 words, to yield highly relevant and accurate search results. Only provide 2 YouTube search terms, each separated by a new line, and nothing else. Search terms must not be in bullet point format. The search term should be highy relevant with the $incorrectCategories and $category !!");

    // print(response);
    // print(response?.output);

    if (response != null && response.output != null) {
      List<String>? searchTerm = response.output!.split('\n');

      // Call fetchVideos with search terms
      await fetchVideos(searchTerm);

      await Future.delayed(const Duration(seconds: 1));
      return true;
    } else {
      print("Empty response from Gemini API");
      return false;
    }
  } catch (error) {
    print("Error processing categories: $error");
    return false;
  }
}
