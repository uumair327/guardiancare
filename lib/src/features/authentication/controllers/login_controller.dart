import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<UserCredential?> signInWithGoogle() async {
  try {
    print("Attempting Google Sign-In...");
    
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    print(googleUser);

    if (googleUser == null) {
      print("User canceled Google Sign-In");
      return null;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    print(googleAuth);

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    print(credential);

    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    print(userCredential.user);

    final user = userCredential.user;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'displayName': googleUser.displayName,
          'email': user.email,
          'photoURL': user.photoURL,
          'uid': user.uid,
        });
      }
    }

    return userCredential;
  } on Exception catch (e) {
    print("Error signing in with Google: $e");
    
    return null;
  }
}

Future<bool> signOutFromGoogle() async {
  try {
    await FirebaseAuth.instance.signOut();

    return true;
  } on Exception catch (e) {
    print("Error signing out: $e");

    return false;
  }
}