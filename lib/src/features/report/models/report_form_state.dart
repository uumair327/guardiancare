import 'package:flutter/foundation.dart';

/// Manages the state of a report form with checkbox selections
class ReportFormState extends ChangeNotifier {
  final String _caseName;
  final List<String> _questions;
  
  // Map to track checkbox states by question index
  Map<int, bool> _checkboxStates = {};
  
  // Track form submission state
  bool _isSubmitting = false;
  
  // Track validation errors
  String? _validationError;
  
  // Track if form has been modified
  bool _isDirty = false;

  ReportFormState({
    required String caseName,
    required List<String> questions,
  }) : _caseName = caseName, _questions = questions {
    _initializeStates();
  }

  // Getters
  String get caseName => _caseName;
  List<String> get questions => List.unmodifiable(_questions);
  Map<int, bool> get checkboxStates => Map.unmodifiable(_checkboxStates);
  bool get isSubmitting => _isSubmitting;
  String? get validationError => _validationError;
  bool get isDirty => _isDirty;
  
  /// Get the number of selected items
  int get selectedCount => _checkboxStates.values.where((selected) => selected).length;
  
  /// Get the total number of questions
  int get totalCount => _questions.length;
  
  /// Check if any items are selected
  bool get hasSelections => selectedCount > 0;
  
  /// Get list of selected question indices
  List<int> get selectedIndices {
    return _checkboxStates.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }
  
  /// Get list of selected questions
  List<String> get selectedQuestions {
    return selectedIndices
        .where((index) => index < _questions.length)
        .map((index) => _questions[index])
        .toList();
  }

  /// Initialize all checkbox states to false
  void _initializeStates() {
    _checkboxStates.clear();
    for (int i = 0; i < _questions.length; i++) {
      _checkboxStates[i] = false;
    }
    _isDirty = false;
  }

  /// Update checkbox state for a specific question
  void updateCheckboxState(int index, bool value) {
    if (index < 0 || index >= _questions.length) {
      throw ArgumentError('Invalid question index: $index');
    }
    
    if (_checkboxStates[index] != value) {
      _checkboxStates[index] = value;
      _isDirty = true;
      _validationError = null; // Clear validation error on change
      notifyListeners();
    }
  }

  /// Get checkbox state for a specific question
  bool getCheckboxState(int index) {
    if (index < 0 || index >= _questions.length) {
      return false;
    }
    return _checkboxStates[index] ?? false;
  }

  /// Toggle checkbox state for a specific question
  void toggleCheckboxState(int index) {
    updateCheckboxState(index, !getCheckboxState(index));
  }

  /// Select all checkboxes
  void selectAll() {
    bool hasChanges = false;
    for (int i = 0; i < _questions.length; i++) {
      if (!_checkboxStates[i]!) {
        _checkboxStates[i] = true;
        hasChanges = true;
      }
    }
    
    if (hasChanges) {
      _isDirty = true;
      _validationError = null;
      notifyListeners();
    }
  }

  /// Deselect all checkboxes
  void deselectAll() {
    bool hasChanges = false;
    for (int i = 0; i < _questions.length; i++) {
      if (_checkboxStates[i]!) {
        _checkboxStates[i] = false;
        hasChanges = true;
      }
    }
    
    if (hasChanges) {
      _isDirty = true;
      notifyListeners();
    }
  }

  /// Clear all form data
  void clearForm() {
    _initializeStates();
    _validationError = null;
    _isSubmitting = false;
    notifyListeners();
  }

  /// Validate the form
  bool validateForm() {
    if (selectedCount == 0) {
      _validationError = 'Please select at least one item before submitting.';
      notifyListeners();
      return false;
    }
    
    _validationError = null;
    notifyListeners();
    return true;
  }

  /// Set submission state
  void setSubmissionState(bool isSubmitting) {
    if (_isSubmitting != isSubmitting) {
      _isSubmitting = isSubmitting;
      notifyListeners();
    }
  }

  /// Set validation error
  void setValidationError(String? error) {
    if (_validationError != error) {
      _validationError = error;
      notifyListeners();
    }
  }

  /// Load state from a map (for persistence)
  void loadFromMap(Map<String, dynamic> data) {
    try {
      final states = data['checkboxStates'] as Map<String, dynamic>?;
      if (states != null) {
        _checkboxStates.clear();
        states.forEach((key, value) {
          final index = int.tryParse(key);
          if (index != null && index < _questions.length && value is bool) {
            _checkboxStates[index] = value;
          }
        });
        _isDirty = data['isDirty'] as bool? ?? false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading report form state: $e');
    }
  }

  /// Save state to a map (for persistence)
  Map<String, dynamic> toMap() {
    return {
      'caseName': _caseName,
      'checkboxStates': _checkboxStates.map((key, value) => MapEntry(key.toString(), value)),
      'isDirty': _isDirty,
      'selectedCount': selectedCount,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Get form summary for display
  ReportFormSummary getSummary() {
    return ReportFormSummary(
      caseName: _caseName,
      totalQuestions: totalCount,
      selectedCount: selectedCount,
      selectedQuestions: selectedQuestions,
      isDirty: _isDirty,
      hasValidationError: _validationError != null,
      validationError: _validationError,
    );
  }

  @override
  String toString() {
    return 'ReportFormState{caseName: $_caseName, selected: $selectedCount/$totalCount, dirty: $_isDirty}';
  }
}

/// Summary information about a report form
class ReportFormSummary {
  final String caseName;
  final int totalQuestions;
  final int selectedCount;
  final List<String> selectedQuestions;
  final bool isDirty;
  final bool hasValidationError;
  final String? validationError;

  const ReportFormSummary({
    required this.caseName,
    required this.totalQuestions,
    required this.selectedCount,
    required this.selectedQuestions,
    required this.isDirty,
    required this.hasValidationError,
    this.validationError,
  });

  /// Get completion percentage
  double get completionPercentage {
    if (totalQuestions == 0) return 0.0;
    return selectedCount / totalQuestions;
  }

  /// Check if form is complete (has selections)
  bool get isComplete => selectedCount > 0;

  /// Get user-friendly status message
  String get statusMessage {
    if (hasValidationError && validationError != null) {
      return validationError!;
    }
    
    if (selectedCount == 0) {
      return 'No items selected';
    }
    
    if (selectedCount == totalQuestions) {
      return 'All items selected';
    }
    
    return '$selectedCount of $totalQuestions items selected';
  }

  @override
  String toString() {
    return 'ReportFormSummary{case: $caseName, selected: $selectedCount/$totalQuestions}';
  }
}