import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<String>> fetchCategories(List<String> categories) async {
  final url = 'https://example.com/gemini-api'; // Replace with your Gemini API endpoint
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer YOUR_API_TOKEN', // Replace with your API token if needed
    },
    body: json.encode({'categories': categories}),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return List<String>.from(data);
  } else {
    throw Exception('Failed to fetch summarized categories');
  }
}
