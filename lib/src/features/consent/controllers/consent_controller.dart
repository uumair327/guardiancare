import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:http/http.dart' as http;


class ConsentController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? generatedOtp;
  String? keyPhrase;
  String? originalKeyPhrase;

  String hashKeyPhrase(String keyPhrase) {
    final bytes = utf8.encode(keyPhrase); // Convert string to bytes
    final hash = sha256.convert(bytes); // Perform SHA-256 hashing
    return hash.toString();
  }

  Future<bool> sendEmail(String recipientEmail, String parentName, String otp, String keyphrase) async {
    String username = 'iichipc1@gmail.com';
    String password = '@Darsh8304';

    final smtpServer = gmail(username, password); // You can use SMTP server details here

    final message = Message()
      ..from = Address(username, 'GuardianCare')
      ..recipients.add(recipientEmail)
      ..subject = 'guardianCare x childrenofIndia: Parent Control Form'
      ..text = '''
      Hey $parentName,

      Thank you for taking your child's safety into consideration. At guardianCare, we ensure that all study content in our app is verified and filtered by the childrenofIndia organization first. We prioritize the complete safety of your child while they use our app.

      Here is the OTP for your verification process:  
      $otp  
      Please enter it to start using the app securely.

      Additionally, here's your Keyphrase:  
      $keyphrase  
      We have blocked certain features for your children, and they can only be accessed using this keyphrase. Please keep it safe and out of your child’s reach. You’ll need to enter it whenever your child wishes to access the following restricted features:

      **Blocked features that require the secure keyphrase:**  
      - A Social Forum  
      - User Profile  
      - Mail to Organization  

      Thank you for your trust and support! We encourage you to continue using the app and ensure that your child is exposed to the right content at the right time.

      Best regards,  
      GuardianCare
      ''';

    

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: $sendReport');
      return true;
    } catch (e) {
      print('Message not sent. Error: $e');
      return false;
    }
  }

  void generateOtpAndKeyPhrase() {
    // Generate OTP
    final random = Random.secure();
    generatedOtp = (random.nextInt(900000) + 100000).toString();

    // Generate Key Phrase
    const length = 16;
    const charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@#\$%&*!';
    originalKeyPhrase = List.generate(length, (_) => charset[Random.secure().nextInt(charset.length)]).join();

    keyPhrase = hashKeyPhrase(originalKeyPhrase!);
  }

  // Method to submit consent form data to Firestore
  Future<bool> submitConsentForm({
    required String parentName,
    required String parentEmail,
    required String childName,
    required bool isChildAbove12,
    required bool isParentConsentGiven,
  }) async {
    try {
      // Ensure user is authenticated
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User is not authenticated.');
      }

      // Prepare the data to be saved in Firestore
      final formData = {
        'parentName': parentName,
        'parentEmail': parentEmail,
        'childName': childName,
        'isChildAbove12': isChildAbove12,
        'isParentConsentGiven': isParentConsentGiven,
        'userEmail': user.email,  // Include the current user's email
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user.uid, // Associate the form with the current user
        'keyphrase': keyPhrase,
      };

      bool emailSent = await sendEmail(parentName, parentEmail, generatedOtp!, originalKeyPhrase!);
      if (!emailSent) {
        return false; // Return false if email wasn't sent successfully
      }

      // Save the data to Firestore
      await _firestore.collection('consents').add(formData);
      print('Consent form data saved successfully.');

      return true;
    } catch (e) {
      throw Exception('Error saving consent data: $e');
    }
  }

  bool verifyOtp(String otp) {

    return true;
    // if (generatedOtp != null && generatedOtp == otp) 
    // {
    //   return true;  // OTP is correct
    // }
    
    // return false;  // OTP is incorrect
  }
}
