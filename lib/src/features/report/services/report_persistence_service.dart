import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/report_form_state.dart';

/// Service for persisting report form state across app sessions
class ReportPersistenceService {
  static const String _keyPrefix = 'report_form_';
  static const String _metadataKey = 'report_forms_metadata';
  static const int _currentVersion = 1;

  /// Save report form state with metadata
  static Future<bool> saveFormState(ReportFormState formState) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateKey = '$_keyPrefix${formState.caseName}';
      
      // Create state data with version and timestamp
      final stateData = {
        ...formState.toMap(),
        'version': _currentVersion,
        'savedAt': DateTime.now().toIso8601String(),
      };
      
      // Save the form state
      await prefs.setString(stateKey, jsonEncode(stateData));
      
      // Update metadata
      await _updateMetadata(formState.caseName, stateData);
      
      debugPrint('Saved report form state for: ${formState.caseName}');
      return true;
    } catch (e) {
      debugPrint('Error saving report form state: $e');
      return false;
    }
  }

  /// Load report form state
  static Future<Map<String, dynamic>?> loadFormState(String caseName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateKey = '$_keyPrefix$caseName';
      final savedState = prefs.getString(stateKey);
      
      if (savedState != null) {
        final stateData = jsonDecode(savedState) as Map<String, dynamic>;
        
        // Check version compatibility
        final version = stateData['version'] as int? ?? 0;
        if (version > _currentVersion) {
          debugPrint('Saved state version ($version) is newer than current version ($_currentVersion)');
          return null;
        }
        
        // Migrate if necessary
        if (version < _currentVersion) {
          final migratedData = await _migrateStateData(stateData, version);
          if (migratedData != null) {
            await saveFormStateData(caseName, migratedData);
            return migratedData;
          }
        }
        
        debugPrint('Loaded report form state for: $caseName');
        return stateData;
      }
    } catch (e) {
      debugPrint('Error loading report form state: $e');
    }
    
    return null;
  }

  /// Save raw form state data
  static Future<bool> saveFormStateData(String caseName, Map<String, dynamic> stateData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateKey = '$_keyPrefix$caseName';
      
      await prefs.setString(stateKey, jsonEncode(stateData));
      await _updateMetadata(caseName, stateData);
      
      return true;
    } catch (e) {
      debugPrint('Error saving form state data: $e');
      return false;
    }
  }

  /// Delete saved form state
  static Future<bool> deleteFormState(String caseName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateKey = '$_keyPrefix$caseName';
      
      final removed = await prefs.remove(stateKey);
      if (removed) {
        await _removeFromMetadata(caseName);
        debugPrint('Deleted report form state for: $caseName');
      }
      
      return removed;
    } catch (e) {
      debugPrint('Error deleting report form state: $e');
      return false;
    }
  }

  /// Get all saved form names
  static Future<List<String>> getSavedFormNames() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      return keys
          .where((key) => key.startsWith(_keyPrefix))
          .map((key) => key.replaceFirst(_keyPrefix, ''))
          .toList();
    } catch (e) {
      debugPrint('Error getting saved form names: $e');
      return [];
    }
  }

  /// Get metadata for all saved forms
  static Future<List<ReportFormMetadata>> getSavedFormsMetadata() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadataJson = prefs.getString(_metadataKey);
      
      if (metadataJson != null) {
        final metadataList = jsonDecode(metadataJson) as List<dynamic>;
        return metadataList
            .map((item) => ReportFormMetadata.fromMap(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error getting forms metadata: $e');
    }
    
    return [];
  }

  /// Check if a form has saved state
  static Future<bool> hasFormState(String caseName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateKey = '$_keyPrefix$caseName';
      return prefs.containsKey(stateKey);
    } catch (e) {
      debugPrint('Error checking form state existence: $e');
      return false;
    }
  }

  /// Get the size of saved form data (for debugging/monitoring)
  static Future<int> getFormStateSize(String caseName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateKey = '$_keyPrefix$caseName';
      final savedState = prefs.getString(stateKey);
      
      return savedState?.length ?? 0;
    } catch (e) {
      debugPrint('Error getting form state size: $e');
      return 0;
    }
  }

  /// Clear all saved form states
  static Future<bool> clearAllFormStates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      final formKeys = keys.where((key) => key.startsWith(_keyPrefix)).toList();
      
      for (final key in formKeys) {
        await prefs.remove(key);
      }
      
      // Clear metadata
      await prefs.remove(_metadataKey);
      
      debugPrint('Cleared ${formKeys.length} saved form states');
      return true;
    } catch (e) {
      debugPrint('Error clearing all form states: $e');
      return false;
    }
  }

  /// Update metadata for a saved form
  static Future<void> _updateMetadata(String caseName, Map<String, dynamic> stateData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingMetadata = await getSavedFormsMetadata();
      
      // Remove existing metadata for this case
      existingMetadata.removeWhere((metadata) => metadata.caseName == caseName);
      
      // Add new metadata
      final newMetadata = ReportFormMetadata(
        caseName: caseName,
        selectedCount: stateData['selectedCount'] as int? ?? 0,
        totalQuestions: (stateData['checkboxStates'] as Map?)?.length ?? 0,
        lastModified: DateTime.tryParse(stateData['savedAt'] as String? ?? '') ?? DateTime.now(),
        version: stateData['version'] as int? ?? _currentVersion,
      );
      
      existingMetadata.add(newMetadata);
      
      // Save updated metadata
      final metadataJson = jsonEncode(existingMetadata.map((m) => m.toMap()).toList());
      await prefs.setString(_metadataKey, metadataJson);
    } catch (e) {
      debugPrint('Error updating metadata: $e');
    }
  }

  /// Remove form from metadata
  static Future<void> _removeFromMetadata(String caseName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingMetadata = await getSavedFormsMetadata();
      
      existingMetadata.removeWhere((metadata) => metadata.caseName == caseName);
      
      final metadataJson = jsonEncode(existingMetadata.map((m) => m.toMap()).toList());
      await prefs.setString(_metadataKey, metadataJson);
    } catch (e) {
      debugPrint('Error removing from metadata: $e');
    }
  }

  /// Migrate state data from older versions
  static Future<Map<String, dynamic>?> _migrateStateData(
    Map<String, dynamic> oldData, 
    int fromVersion
  ) async {
    try {
      Map<String, dynamic> migratedData = Map.from(oldData);
      
      // Migration logic for different versions
      if (fromVersion < 1) {
        // Migration from version 0 to 1
        // Add any new fields or restructure data as needed
        migratedData['version'] = 1;
        migratedData['migratedAt'] = DateTime.now().toIso8601String();
      }
      
      debugPrint('Migrated report form state from version $fromVersion to $_currentVersion');
      return migratedData;
    } catch (e) {
      debugPrint('Error migrating state data: $e');
      return null;
    }
  }

  /// Get storage statistics
  static Future<ReportStorageStats> getStorageStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final formKeys = keys.where((key) => key.startsWith(_keyPrefix)).toList();
      
      int totalSize = 0;
      for (final key in formKeys) {
        final value = prefs.getString(key);
        totalSize += value?.length ?? 0;
      }
      
      final metadata = await getSavedFormsMetadata();
      
      return ReportStorageStats(
        totalForms: formKeys.length,
        totalStorageSize: totalSize,
        averageFormSize: formKeys.isNotEmpty ? totalSize / formKeys.length : 0,
        oldestForm: metadata.isNotEmpty 
            ? metadata.map((m) => m.lastModified).reduce((a, b) => a.isBefore(b) ? a : b)
            : null,
        newestForm: metadata.isNotEmpty
            ? metadata.map((m) => m.lastModified).reduce((a, b) => a.isAfter(b) ? a : b)
            : null,
      );
    } catch (e) {
      debugPrint('Error getting storage stats: $e');
      return const ReportStorageStats(
        totalForms: 0,
        totalStorageSize: 0,
        averageFormSize: 0,
      );
    }
  }
}

/// Metadata for a saved report form
class ReportFormMetadata {
  final String caseName;
  final int selectedCount;
  final int totalQuestions;
  final DateTime lastModified;
  final int version;

  const ReportFormMetadata({
    required this.caseName,
    required this.selectedCount,
    required this.totalQuestions,
    required this.lastModified,
    required this.version,
  });

  factory ReportFormMetadata.fromMap(Map<String, dynamic> map) {
    return ReportFormMetadata(
      caseName: map['caseName'] as String,
      selectedCount: map['selectedCount'] as int,
      totalQuestions: map['totalQuestions'] as int,
      lastModified: DateTime.parse(map['lastModified'] as String),
      version: map['version'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'caseName': caseName,
      'selectedCount': selectedCount,
      'totalQuestions': totalQuestions,
      'lastModified': lastModified.toIso8601String(),
      'version': version,
    };
  }

  /// Get completion percentage
  double get completionPercentage {
    if (totalQuestions == 0) return 0.0;
    return selectedCount / totalQuestions;
  }

  /// Check if form is complete
  bool get isComplete => selectedCount > 0;

  /// Get age of the saved form
  Duration get age => DateTime.now().difference(lastModified);

  /// Check if form is recent (less than 24 hours old)
  bool get isRecent => age.inHours < 24;

  @override
  String toString() {
    return 'ReportFormMetadata{case: $caseName, selected: $selectedCount/$totalQuestions, age: ${age.inHours}h}';
  }
}

/// Storage statistics for report forms
class ReportStorageStats {
  final int totalForms;
  final int totalStorageSize;
  final double averageFormSize;
  final DateTime? oldestForm;
  final DateTime? newestForm;

  const ReportStorageStats({
    required this.totalForms,
    required this.totalStorageSize,
    required this.averageFormSize,
    this.oldestForm,
    this.newestForm,
  });

  /// Get storage size in KB
  double get storageSizeKB => totalStorageSize / 1024;

  /// Get storage size in MB
  double get storageSizeMB => storageSizeKB / 1024;

  /// Get age range of saved forms
  Duration? get formAgeRange {
    if (oldestForm == null || newestForm == null) return null;
    return newestForm!.difference(oldestForm!);
  }

  @override
  String toString() {
    return 'ReportStorageStats{forms: $totalForms, size: ${storageSizeKB.toStringAsFixed(1)}KB}';
  }
}