import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<UserCredential?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    
    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

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