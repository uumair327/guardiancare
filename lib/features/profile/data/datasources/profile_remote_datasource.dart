import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:guardiancare/core/error/exceptions.dart';
import 'package:guardiancare/features/profile/data/models/profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remote data source for profile operations
abstract class ProfileRemoteDataSource {
  /// Get user profile from Firestore
  Future<ProfileModel> getProfile(String uid);

  /// Update user profile in Firestore
  Future<void> updateProfile(ProfileModel profile);

  /// Delete user account and all associated data
  Future<void> deleteAccount(String uid);

  /// Clear user preferences from local storage
  Future<void> clearUserPreferences();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final SharedPreferences sharedPreferences;

  ProfileRemoteDataSourceImpl({
    required this.firestore,
    required this.auth,
    required this.sharedPreferences,
  });

  @override
  Future<ProfileModel> getProfile(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        throw ServerException('User profile not found');
      }

      final data = doc.data();
      if (data == null) {
        throw ServerException('User profile data is null');
      }

      return ProfileModel.fromJson(data);
    } catch (e) {
      throw ServerException('Failed to get profile: ${e.toString()}');
    }
  }

  @override
  Future<void> updateProfile(ProfileModel profile) async {
    try {
      await firestore.collection('users').doc(profile.uid).update(
            profile.toJson(),
          );
    } catch (e) {
      throw ServerException('Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAccount(String uid) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        throw ServerException('No user is currently signed in');
      }

      // Delete user's recommendations
      await _deleteUserRecommendations(uid);

      // Delete user document from Firestore
      await firestore.collection('users').doc(uid).delete();

      // Reauthenticate if needed and delete Firebase Auth account
      await _deleteFirebaseAuthAccount(user);
    } catch (e) {
      throw ServerException('Failed to delete account: ${e.toString()}');
    }
  }

  @override
  Future<void> clearUserPreferences() async {
    try {
      await sharedPreferences.remove('has_seen_forum_guidelines');
    } catch (e) {
      throw CacheException('Failed to clear preferences: ${e.toString()}');
    }
  }

  /// Delete user recommendations from Firestore
  Future<void> _deleteUserRecommendations(String uid) async {
    try {
      final recommendations = await firestore
          .collection('recommendations')
          .where('userId', isEqualTo: uid)
          .get();

      for (var doc in recommendations.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      // Log error but don't throw - recommendations deletion is not critical
      print('Error deleting recommendations: $e');
    }
  }

  /// Delete Firebase Auth account with reauthentication if needed
  Future<void> _deleteFirebaseAuthAccount(User user) async {
    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == "requires-recent-login") {
        await _reauthenticateAndDelete(user);
      } else {
        throw ServerException('Failed to delete auth account: ${e.message}');
      }
    }
  }

  /// Reauthenticate user and delete account
  Future<void> _reauthenticateAndDelete(User user) async {
    try {
      final providerData = user.providerData.first;

      if (GoogleAuthProvider().providerId == providerData.providerId) {
        await user.reauthenticateWithProvider(GoogleAuthProvider());
      }

      await user.delete();
    } catch (e) {
      throw ServerException('Failed to reauthenticate and delete: ${e.toString()}');
    }
  }
}
