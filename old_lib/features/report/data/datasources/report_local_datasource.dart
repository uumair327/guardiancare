import 'dart:convert';
import 'package:guardiancare/core/error/exceptions.dart';
import 'package:guardiancare/features/report/data/models/report_model.dart';
import 'package:guardiancare/core/database/hive_service.dart';

/// Local data source for report operations
/// Uses Hive for fast, efficient storage of report data
/// Follows Clean Architecture: Data layer can depend on infrastructure
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
  final HiveService _hiveService;
  static const String _boxName = 'reports';
  static const String _keyPrefix = 'report_form_';

  ReportLocalDataSourceImpl({required HiveService hiveService})
      : _hiveService = hiveService;

  @override
  Future<void> saveReport(ReportModel report) async {
    try {
      final key = '$_keyPrefix${report.caseName}';
      final json = report.toJson();
      json['version'] = 1;

      await _hiveService.put(_boxName, key, json);
    } catch (e) {
      throw CacheException('Failed to save report: ${e.toString()}');
    }
  }

  @override
  Future<ReportModel> loadReport(
      String caseName, List<String> questions) async {
    try {
      final key = '$_keyPrefix$caseName';
      final json = _hiveService.get<Map<dynamic, dynamic>>(_boxName, key);

      if (json == null) {
        throw CacheException('Report not found: $caseName');
      }

      final jsonMap = Map<String, dynamic>.from(json);
      final model = ReportModel.fromJson(jsonMap);

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
      await _hiveService.delete(_boxName, key);
    } catch (e) {
      throw CacheException('Failed to delete report: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getSavedReportNames() async {
    try {
      final keys = _hiveService.getKeys(_boxName);

      return keys
          .where((key) => key.toString().startsWith(_keyPrefix))
          .map((key) => key.toString().replaceFirst(_keyPrefix, ''))
          .toList();
    } catch (e) {
      throw CacheException('Failed to get saved reports: ${e.toString()}');
    }
  }

  @override
  Future<bool> reportExists(String caseName) async {
    try {
      final key = '$_keyPrefix$caseName';
      return _hiveService.containsKey(_boxName, key);
    } catch (e) {
      throw CacheException(
          'Failed to check report existence: ${e.toString()}');
    }
  }
}
