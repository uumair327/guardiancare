import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guardiancare/src/features/explore/models/resource_model.dart';


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
Stream<List<Resource>> getRecommendedResources() {
    return FirebaseFirestore.instance
        .collection('resources')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Resource.fromDocumentSnapshot(
                doc.data() as Map<String, dynamic>))
            .toList());
  }
}
