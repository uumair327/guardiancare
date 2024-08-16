import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> _reauthenticateAndDelete() async {
  try {
    final providerData = FirebaseAuth.instance.currentUser?.providerData.first;

    if (GoogleAuthProvider().providerId == providerData?.providerId) {
      await FirebaseAuth.instance.currentUser!
          .reauthenticateWithProvider(GoogleAuthProvider());
    }

    await FirebaseAuth.instance.currentUser?.delete();
  } catch (e) {
    // Handle exceptions
  }
}

Future<void> _deleteUserRecommendations(String uid) async {
  try {
    final recommendations = await FirebaseFirestore.instance
        .collection('recommendations')
        .where('userId', isEqualTo: uid)
        .get();

    for (var doc in recommendations.docs) {
      await doc.reference.delete();
    }
  } catch (e) {
    // Handle exceptions related to deleting recommendations
    print('Error deleting recommendations: $e');
  }
}

Future<bool> deleteUserAccount() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false; // Handle case where user is null

    // Delete user's recommended videos
    await _deleteUserRecommendations(user.uid);

    // Delete user document
    await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

    // Delete user authentication
    await user.delete();

    return true;
  } on FirebaseAuthException catch (e) {
    print(e);

    if (e.code == "requires-recent-login") {
      await _reauthenticateAndDelete();
    } else {
      // Handle other Firebase exceptions
    }

    return true;
  } catch (e) {
    print(e);

    return false;
  }
}
