import 'package:cloud_firestore/cloud_firestore.dart';

class HomeController {
  Future<List<Map<String, dynamic>>> fetchCarouselData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('carousel_items').get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching carousel data: $e');
      return [];
    }
  }
}
