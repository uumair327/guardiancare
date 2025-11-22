import 'dart:convert';
import 'package:guardiancare/core/error/exceptions.dart';
import 'package:guardiancare/features/report/data/models/report_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for report operations
abstract class ReportLocalDataSource {
  /// Save report to local storage
  Future<void> saveReport(ReportModel report);

  /// Load report from local storage
  Future<ReportModel> loadReport(String caseName, List<String> questions);

  /// Delete report from local storage
  Future<void> deleteReport(String caseName);

  /// Get all saved report names
  Future<List<String>> getSavedReportNames();

  /// Check if report exists
  Future<bool> reportExists(String caseName);
}

class ReportLocalDataSourceImpl implements ReportLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _keyPrefix = 'report_form_';

  ReportLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveReport(ReportModel report) async {
    try {
      final key = '$_keyPrefix${report.caseName}';
      final json = report.toJson();
      json['version'] = 1;

      await sharedPreferences.setString(key, jsonEncode(json));
    } catch (e) {
      throw CacheException('Failed to save report: ${e.toString()}');
    }
  }

  @override
  Future<ReportModel> loadReport(
      String caseName, List<String> questions) async {
    try {
      final key = '$_keyPrefix$caseName';
      final jsonString = sharedPreferences.getString(key);

      if (jsonString == null) {
        throw CacheException('Report not found: $caseName');
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final model = ReportModel.fromJson(json);

      // Add questions back (they're not stored in JSON)
      return ReportModel(
        caseName: model.caseName,
        questions: questions,
        answers: model.answers,
        savedAt: model.savedAt,
        isDirty: model.isDirty,
      );
    } catch (e) {
      throw CacheException('Failed to load report: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteReport(String caseName) async {
    try {
      final key = '$_keyPrefix$caseName';
      final removed = await sharedPreferences.remove(key);

      if (!removed) {
        throw CacheException('Failed to delete report: $caseName');
      }
    } catch (e) {
      throw CacheException('Failed to delete report: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getSavedReportNames() async {
    try {
      final keys = sharedPreferences.getKeys();

      return keys
          .where((key) => key.startsWith(_keyPrefix))
          .map((key) => key.replaceFirst(_keyPrefix, ''))
          .toList();
    } catch (e) {
      throw CacheException('Failed to get saved reports: ${e.toString()}');
    }
  }

  @override
  Future<bool> reportExists(String caseName) async {
    try {
      final key = '$_keyPrefix$caseName';
      return sharedPreferences.containsKey(key);
    } catch (e) {
      throw CacheException(
          'Failed to check report existence: ${e.toString()}');
    }
  }
}
