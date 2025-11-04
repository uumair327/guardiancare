

import 'package:flutter/material.dart';
import '../controllers/report_form_controller.dart';
import '../models/report_form_state.dart';

class CaseQuestionsPage extends StatefulWidget {
  final String caseName;
  final List<String> questions;

  const CaseQuestionsPage(this.caseName, this.questions, {super.key});

  @override
  State<CaseQuestionsPage> createState() => _CaseQuestionsPageState();
}

class _CaseQuestionsPageState extends State<CaseQuestionsPage> {
  late ReportFormController _formController;

  @override
  void initState() {
    super.initState();
    _formController = ReportFormController();
    _formController.addListener(_onFormControllerChanged);
    _formController.initializeForm(widget.caseName, widget.questions);
  }

  @override
  void dispose() {
    _formController.removeListener(_onFormControllerChanged);
    _formController.dispose();
    super.dispose();
  }

  void _onFormControllerChanged() {
    if (mounted) {
      setState(() {
        // Trigger rebuild when form controller state changes
      });
    }
  }

  /// Get current form state
  ReportFormState? get _formState => _formController.currentFormState;
  
  /// Check if form is currently being submitted
  bool get _isSubmitting => _formState?.isSubmitting ?? false;
  
  /// Get current validation error
  String? get _validationError => _formState?.validationError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(caseName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCaseTitle(),
            const SizedBox(height: 20),
            _buildQuestionList(),
            const SizedBox(height: 20),
            if (_formController.isLoading) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ] else if (_validationError != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _validationError!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSubmitting
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text('Submitting...'),
                            ],
                          )
                        : const Text('Submit Report'),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleClearForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  ),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseTitle() {
    return Text(
      'Report $caseName',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildQuestionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Please select all that apply to your situation:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        ...widget.questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (_formState?.getCheckboxState(index) ?? false)
                    ? Theme.of(context).primaryColor.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
              ),
              color: (_formState?.getCheckboxState(index) ?? false)
                  ? Theme.of(context).primaryColor.withOpacity(0.05)
                  : null,
            ),
            child: CheckboxListTile(
              title: Text(
                question,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: (_formState?.getCheckboxState(index) ?? false)
                      ? FontWeight.w500 
                      : FontWeight.normal,
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              value: _formState?.getCheckboxState(index) ?? false,
              onChanged: _isSubmitting ? null : (bool? value) {
                _handleCheckboxChange(index, value ?? false);
              },
              activeColor: Theme.of(context).primaryColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        }).toList(),
        const SizedBox(height: 16),
        _buildSelectionSummary(),
      ],
    );
  }

  /// Build a summary of selected items
  Widget _buildSelectionSummary() {
    final selectedCount = _formState?.selectedCount ?? 0;
    final totalCount = _formState?.totalCount ?? widget.questions.length;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            selectedCount > 0 ? Icons.check_circle_outline : Icons.info_outline,
            color: selectedCount > 0 ? Colors.green : Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              selectedCount > 0 
                  ? 'Selected $selectedCount of $totalCount items'
                  : 'No items selected yet',
              style: TextStyle(
                color: selectedCount > 0 ? Colors.green[700] : Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handle checkbox state change
  void _handleCheckboxChange(int index, bool value) {
    _formController.updateCheckboxState(index, value);
  }

  /// Handle form submission
  Future<void> _handleSubmit() async {
    final result = await _formController.submitForm();
    
    if (mounted) {
      if (result.success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate back with selected questions
        Navigator.of(context).pop(result.selectedQuestions);
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Handle form clearing
  Future<void> _handleClearForm() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Form'),
        content: const Text('Are you sure you want to clear all selections? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      await _formController.clearForm();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Form cleared successfully.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
