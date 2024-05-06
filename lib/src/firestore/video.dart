import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> fetchVideos() async {
  try {
    FirebaseFirestore db = FirebaseFirestore.instance;
    final querySnapshot = await db.collection('videos').get();
    List<Map<String, dynamic>> videos = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data();
      data['id'] = doc.id; // Add document ID to the data map
      return data;
    }).toList();
    return videos;
  } catch (e) {
    print('Error fetching videos: $e');
    return [];
  }
}
