import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/src/features/report/bloc/report_bloc.dart';
import 'package:guardiancare/src/core/logging/app_logger.dart';

class CaseQuestionsPageBloc extends StatelessWidget {
  final String caseName;
  final List<String> questions;

  const CaseQuestionsPageBloc(this.caseName, this.questions, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportBloc()..add(CreateReport(caseName, questions)),
      child: _CaseQuestionsView(caseName: caseName, questions: questions),
    );
  }
}

class _CaseQuestionsView extends StatelessWidget {
  final String caseName;
  final List<String> questions;

  const _CaseQuestionsView({
    required this.caseName,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(caseName),
      ),
      body: BlocConsumer<ReportBloc, ReportState>(
        listener: (context, state) {
          if (state is ReportSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Report saved successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
            
            // Get selected questions
            final selectedQuestions = <String>[];
            for (int i = 0; i < questions.length; i++) {
              if (state.formState.isAnswerChecked(i)) {
                selectedQuestions.add(questions[i]);
              }
            }
            
            Navigator.of(context).pop(selectedQuestions);
            AppLogger.feature('Report', 'Report submitted with ${selectedQuestions.length} items');
          } else if (state is ReportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
            AppLogger.error('Report', 'Report submission failed: ${state.message}');
          }
        },
        builder: (context, state) {
          if (state is ReportLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ReportError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ReportBloc>().add(CreateReport(caseName, questions));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is! ReportLoaded && state is! ReportSaving && state is! ReportSaved) {
            return const Center(
              child: Text('Initializing form...'),
            );
          }

          final formState = state is ReportLoaded 
              ? state.formState 
              : state is ReportSaving 
                  ? state.formState 
                  : (state as ReportSaved).formState;
          
          final isSubmitting = state is ReportSaving;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCaseTitle(),
                const SizedBox(height: 20),
                _buildQuestionList(context, formState, isSubmitting),
                const SizedBox(height: 20),
                _buildActionButtons(context, formState, isSubmitting),
              ],
            ),
          );
        },
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

  Widget _buildQuestionList(BuildContext context, dynamic formState, bool isSubmitting) {
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
        ...questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          final isChecked = formState.isAnswerChecked(index);
          
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isChecked
                    ? Theme.of(context).primaryColor.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
              ),
              color: isChecked
                  ? Theme.of(context).primaryColor.withOpacity(0.05)
                  : null,
            ),
            child: CheckboxListTile(
              title: Text(
                question,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isChecked ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              value: isChecked,
              onChanged: isSubmitting ? null : (bool? value) {
                context.read<ReportBloc>().add(UpdateAnswer(index, value ?? false));
                AppLogger.debug('Report', 'Question $index updated: ${value ?? false}');
              },
              activeColor: Theme.of(context).primaryColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        }).toList(),
        const SizedBox(height: 16),
        _buildSelectionSummary(formState),
      ],
    );
  }

  Widget _buildSelectionSummary(dynamic formState) {
    final selectedCount = formState.selectedCount;
    final totalCount = questions.length;
    
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

  Widget _buildActionButtons(BuildContext context, dynamic formState, bool isSubmitting) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: isSubmitting ? null : () => _handleSubmit(context, formState),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isSubmitting
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
          onPressed: isSubmitting ? null : () => _handleClearForm(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.grey[700],
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
          child: const Text('Clear'),
        ),
      ],
    );
  }

  void _handleSubmit(BuildContext context, dynamic formState) {
    if (formState.selectedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one item before submitting.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    context.read<ReportBloc>().add(const SaveReport());
    AppLogger.bloc('ReportBloc', 'SaveReport', state: 'Saving report with ${formState.selectedCount} items');
  }

  Future<void> _handleClearForm(BuildContext context) async {
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

    if (shouldClear == true && context.mounted) {
      context.read<ReportBloc>().add(CreateReport(caseName, questions));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form cleared successfully.'),
          duration: Duration(seconds: 2),
        ),
      );
      
      AppLogger.feature('Report', 'Form cleared');
    }
  }
}
