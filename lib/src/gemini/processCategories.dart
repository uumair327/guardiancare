import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:guardiancare/src/youtube/fetchVideos.dart';

Future<bool> processCategories(List<String> incorrectCategories, String category) async {
  try {
    Gemini.init(apiKey: "AIzaSyCJz_lIoAxc0ZY1Gk3jBgnLZTKeTbDn6B4", enableDebugging: true);

    final gemini = Gemini.instance;

    final response = await gemini.text("Summarize the subtopics $incorrectCategories under the main topic $category into a single search term for YouTube. The term should effectively encompass all subtopics and the main topic, consisting of 4-5 words, to yield highly relevant and accurate search results. Only provide 3 YouTube search terms, each separated by a new line, and nothing else. Search terms must not be in bullet point format");

    List<String>? searchTerm = response?.output!.split('\n');

    // print(searchTerm);

    await fetchVideos(searchTerm!);

    await Future.delayed(const Duration(seconds: 1));
    return true;
  } catch (error) {
    print("Error processing categories: $error");
    return false;
  }
}
