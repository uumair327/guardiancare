import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExploreController {
  final FirebaseAuth auth = FirebaseAuth.instance;

  User? get currentUser => auth.currentUser;

  Stream<QuerySnapshot> getRecommendedVideos() {
    if (currentUser == null) {
      throw Exception("User not logged in");
    }

    return FirebaseFirestore.instance
        .collection('recommendations')
        .where('UID', isEqualTo: currentUser!.uid)
        .orderBy('timestamp', descending: true)
        .limit(8)
        .snapshots();
  }
}
