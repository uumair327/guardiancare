import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> fetchVideos(List<String> searchTerms) async {
  final firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User? user = auth.currentUser;

  for (String term in searchTerms) {
    if (term == '') {
      continue;
    } else if (term[0] == '-') {
      term = term.substring(2);
    }

    final res = await http.get(Uri.parse(
      'https://www.googleapis.com/youtube/v3/search?part=snippet&q=$term&maxResults=1&key=AIzaSyAIuTQTk0_aEawCBLNX-YZwB6qEuFuHnGg'
    ));

    if (res.statusCode == 200) {
      final response = jsonDecode(res.body);

      final item = response['items'][0];
      final snippet = item['snippet'];

      await firestore.collection('recommendations').add({
        'title': snippet['title'],
        'video': "https://youtu.be/${item['id']['videoId']}",
        'category': term,
        'thumbnail': snippet['thumbnails']['high']['url'],
        'timestamp': FieldValue.serverTimestamp(),
        'UID': user?.uid,
      });
    } else {
      print('Failed to fetch data for term: $term');
    }
  }
}
