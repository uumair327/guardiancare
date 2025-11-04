import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/report_form_state.dart';

/// Controller for managing report form operations and persistence
class ReportFormController extends ChangeNotifier {
  ReportFormState? _currentFormState;
  bool _isLoading = false;
  String? _error;

  // Getters
  ReportFormState? get currentFormState => _currentFormState;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveForm => _currentFormState != null;

  /// Initialize a new report form
  void initializeForm(String caseName, List<String> questions) {
    _currentFormState = ReportFormState(
      caseName: caseName,
      questions: questions,
    );
    
    // Listen to form state changes
    _currentFormState!.addListener(_onFormStateChanged);
    
    _error = null;
    notifyListeners();
    
    // Load any saved state
    _loadFormState();
  }

  /// Handle form state changes
  void _onFormStateChanged() {
    notifyListeners();
    // Auto-save on changes
    _saveFormState();
  }

  /// Update checkbox state
  void updateCheckboxState(int index, bool value) {
    _currentFormState?.updateCheckboxState(index, value);
  }

  /// Toggle checkbox state
  void toggleCheckboxState(int index) {
    _currentFormState?.toggleCheckboxState(index);
  }

  /// Select all checkboxes
  void selectAll() {
    _currentFormState?.selectAll();
  }

  /// Deselect all checkboxes
  void deselectAll() {
    _currentFormState?.deselectAll();
  }

  /// Validate the current form
  bool validateForm() {
    return _currentFormState?.validateForm() ?? false;
  }

  /// Submit the form
  Future<ReportSubmissionResult> submitForm() async {
    if (_currentFormState == null) {
      return ReportSubmissionResult.failure('No active form to submit');
    }

    if (!validateForm()) {
      return ReportSubmissionResult.failure(
        _currentFormState!.validationError ?? 'Form validation failed'
      );
    }

    _currentFormState!.setSubmissionState(true);
    
    try {
      // Simulate form submission
      await Future.delayed(const Duration(seconds: 2));
      
      final selectedQuestions = _currentFormState!.selectedQuestions;
      
      // Clear saved state after successful submission
      await _clearSavedFormState();
      
      // Clear current form state
      _currentFormState!.clearForm();
      
      return ReportSubmissionResult.success(
        selectedQuestions,
        'Report submitted successfully! Selected ${selectedQuestions.length} items.',
      );
      
    } catch (e) {
      _currentFormState!.setValidationError('Failed to submit report: ${e.toString()}');
      return ReportSubmissionResult.failure('Submission failed: ${e.toString()}');
      
    } finally {
      _currentFormState!.setSubmissionState(false);
    }
  }

  /// Clear the current form
  Future<void> clearForm() async {
    _currentFormState?.clearForm();
    await _clearSavedFormState();
  }

  /// Dispose of the current form
  void disposeForm() {
    _currentFormState?.removeListener(_onFormStateChanged);
    _currentFormState?.dispose();
    _currentFormState = null;
    notifyListeners();
  }

  /// Save form state to SharedPreferences
  Future<void> _saveFormState() async {
    if (_currentFormState == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateKey = 'report_form_${_currentFormState!.caseName}';
      final stateData = _currentFormState!.toMap();
      
      await prefs.setString(stateKey, jsonEncode(stateData));
    } catch (e) {
      debugPrint('Error saving report form state: $e');
    }
  }

  /// Load form state from SharedPreferences
  Future<void> _loadFormState() async {
    if (_currentFormState == null) return;
    
    _setLoading(true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateKey = 'report_form_${_currentFormState!.caseName}';
      final savedState = prefs.getString(stateKey);
      
      if (savedState != null) {
        final stateData = jsonDecode(savedState) as Map<String, dynamic>;
        _currentFormState!.loadFromMap(stateData);
      }
    } catch (e) {
      debugPrint('Error loading report form state: $e');
      _setError('Failed to load saved form state');
    } finally {
      _setLoading(false);
    }
  }

  /// Clear saved form state from SharedPreferences
  Future<void> _clearSavedFormState() async {
    if (_currentFormState == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateKey = 'report_form_${_currentFormState!.caseName}';
      await prefs.remove(stateKey);
    } catch (e) {
      debugPrint('Error clearing report form state: $e');
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Set error state
  void _setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  /// Clear error state
  void clearError() {
    _setError(null);
  }

  /// Get form summary
  ReportFormSummary? getFormSummary() {
    return _currentFormState?.getSummary();
  }

  /// Check if form has unsaved changes
  bool hasUnsavedChanges() {
    return _currentFormState?.isDirty ?? false;
  }

  /// Get list of all saved report forms
  Future<List<String>> getSavedFormNames() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      return keys
          .where((key) => key.startsWith('report_form_'))
          .map((key) => key.replaceFirst('report_form_', ''))
          .toList();
    } catch (e) {
      debugPrint('Error getting saved form names: $e');
      return [];
    }
  }

  /// Delete a saved form by name
  Future<bool> deleteSavedForm(String caseName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateKey = 'report_form_$caseName';
      return await prefs.remove(stateKey);
    } catch (e) {
      debugPrint('Error deleting saved form: $e');
      return false;
    }
  }

  @override
  void dispose() {
    disposeForm();
    super.dispose();
  }
}

/// Result of a report form submission
class ReportSubmissionResult {
  final bool success;
  final List<String>? selectedQuestions;
  final String message;
  final String? errorCode;

  const ReportSubmissionResult._({
    required this.success,
    this.selectedQuestions,
    required this.message,
    this.errorCode,
  });

  factory ReportSubmissionResult.success(
    List<String> selectedQuestions,
    String message,
  ) {
    return ReportSubmissionResult._(
      success: true,
      selectedQuestions: selectedQuestions,
      message: message,
    );
  }

  factory ReportSubmissionResult.failure(
    String message, {
    String? errorCode,
  }) {
    return ReportSubmissionResult._(
      success: false,
      message: message,
      errorCode: errorCode,
    );
  }

  @override
  String toString() {
    return 'ReportSubmissionResult{success: $success, message: $message}';
  }
}