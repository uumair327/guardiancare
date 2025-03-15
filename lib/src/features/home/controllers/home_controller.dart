import 'package:cloud_firestore/cloud_firestore.dart';

class HomeController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<Map<String, dynamic>>> fetchCarouselData() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('carousel_items').get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'type': data['type'] ?? 'image',
          'imageUrl': data['imageUrl'],
          'link': data['link'],
          'thumbnailUrl': data['thumbnailUrl'] ?? '',
          'content': data['content'] ?? {},
        };
      }).toList();
    } catch (e) {
      print('Error fetching carousel data: $e');
      return [];
    }
  }
}
