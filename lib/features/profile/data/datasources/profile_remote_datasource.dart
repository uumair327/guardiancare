import 'package:guardiancare/core/backend/backend.dart';
import 'package:guardiancare/core/constants/constants.dart';
import 'package:guardiancare/core/error/exceptions.dart';
import 'package:guardiancare/features/profile/data/models/profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remote data source for profile operations
abstract class ProfileRemoteDataSource {
  /// Get user profile from DataStore
  Future<ProfileModel> getProfile(String uid);

  /// Update user profile in DataStore
  Future<void> updateProfile(ProfileModel profile);

  /// Delete user account and all associated data
  Future<void> deleteAccount(String uid, {String? password});

  /// Clear user preferences from local storage
  Future<void> clearUserPreferences();
}

/// Implementation of ProfileRemoteDataSource using IDataStore and IAuthService
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl({
    required IDataStore dataStore,
    required IAuthService authService,
    required SharedPreferences sharedPreferences,
  })  : _dataStore = dataStore,
        _authService = authService,
        _sharedPreferences = sharedPreferences;
  final IDataStore _dataStore;
  final IAuthService _authService;
  final SharedPreferences _sharedPreferences;

  @override
  Future<ProfileModel> getProfile(String uid) async {
    try {
      final result = await _dataStore.get('users', uid);

      return result.when(
        success: (data) {
          if (data == null) {
            throw const ServerException(ErrorStrings.userNotFound);
          }
          return ProfileModel.fromJson(data);
        },
        failure: (error) {
          throw ServerException(ErrorStrings.withDetails(
              ErrorStrings.getProfileError, error.message));
        },
      );
    } on Object catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          ErrorStrings.withDetails(ErrorStrings.getProfileError, e.toString()));
    }
  }

  @override
  Future<void> updateProfile(ProfileModel profile) async {
    try {
      final result =
          await _dataStore.update('users', profile.uid, profile.toJson());

      if (result.isFailure) {
        throw ServerException(ErrorStrings.withDetails(
            ErrorStrings.updateProfileError, result.errorOrNull!.message));
      }
    } on Object catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(ErrorStrings.withDetails(
          ErrorStrings.updateProfileError, e.toString()));
    }
  }

  @override
  Future<void> deleteAccount(String uid, {String? password}) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw const ServerException(ErrorStrings.userNotFound);
      }

      // Delete user's recommendations
      // Logic: query recommendations where userId == uid, then delete each
      final queryOptions =
          QueryOptions(filters: [QueryFilter.equals('userId', uid)]);
      final recsResult =
          await _dataStore.query('recommendations', options: queryOptions);

      if (recsResult.isSuccess && recsResult.dataOrNull != null) {
        for (final doc in recsResult.dataOrNull!) {
          final docId = doc['id'] as String;
          await _dataStore.delete('recommendations', docId);
        }
      }

      // Delete user document from Data Store
      await _dataStore.delete('users', uid);

      // Delete account (handled by AuthService including re-auth for Google if possible)
      final deleteResult = await _authService.deleteAccount(password: password);

      if (deleteResult.isFailure) {
        throw ServerException(ErrorStrings.withDetails(
            ErrorStrings.deleteAccountError,
            deleteResult.errorOrNull!.message));
      }
    } on Object catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(ErrorStrings.withDetails(
          ErrorStrings.deleteAccountError, e.toString()));
    }
  }

  @override
  Future<void> clearUserPreferences() async {
    try {
      await _sharedPreferences.remove('has_seen_forum_guidelines');
    } on Object catch (e) {
      throw CacheException(ErrorStrings.withDetails(
          ErrorStrings.clearPreferencesError, e.toString()));
    }
  }
}
