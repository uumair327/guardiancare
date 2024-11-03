import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecommendationsRepository {
  final FirebaseFirestore _firestore;
  final User? _user;

  RecommendationsRepository(this._firestore, this._user);

  Future<void> saveRecommendation(
      Map<String, dynamic> videoData, String category) async {
    final snippet = videoData['snippet'];
    final videoId = videoData['id']['videoId'];

    await _firestore.collection('recommendations').add({
      'title': snippet['title'],
      'video': "https://youtu.be/$videoId",
      'category': category,
      'thumbnail': snippet['thumbnails']['high']['url'],
      'timestamp': FieldValue.serverTimestamp(),
      'UID': _user?.uid,
    });
  }
}
