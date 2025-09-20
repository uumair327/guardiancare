import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/core/di/dependency_injection.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import '../models/report.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String? _selectedIncidentType;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _recipientEmailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    _recipientEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DependencyInjection.get<ReportBloc>()
        ..add(const ReportCategoriesRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Report Incident'),
          actions: [
            BlocBuilder<ReportBloc, ReportState>(
              builder: (context, state) {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  return IconButton(
                    icon: const Icon(Icons.history),
                    onPressed: () {
                      context.read<ReportBloc>().add(UserReportsRequested(user.uid));
                    },
                    tooltip: 'View Report History',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocConsumer<ReportBloc, ReportState>(
          listener: (context, state) {
            if (state is ReportSubmitted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              _clearForm();
            } else if (state is ReportError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ReportLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ReportCategoriesLoaded) {
              return _buildReportForm(context, state);
            } else if (state is ReportSubmitting) {
              return _buildSubmittingState();
            } else if (state is UserReportsLoaded) {
              return _buildReportsHistory(context, state);
            } else if (state is ReportError) {
              return _buildErrorState(context, state.message);
            }
            
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildReportForm(BuildContext context, ReportCategoriesLoaded state) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Incident Type *:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedIncidentType,
              items: state.categories.map((category) {
                return DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedIncidentType = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select Incident Type',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select an incident type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _recipientEmailController,
              decoration: const InputDecoration(
                labelText: 'Recipient Email(s) (optional)',
                border: OutlineInputBorder(),
                helperText: 'Separate multiple emails with commas',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final emails = value.split(',').map((e) => e.trim()).toList();
                  final emailRegex = RegExp(r"[^@]+@[^@]+\.[^@]+");
                  for (final email in emails) {
                    if (!emailRegex.hasMatch(email)) {
                      return 'Please enter valid email addresses';
                    }
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: tPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => _submitReport(context),
              child: const Text(
                'Submit Report',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmittingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Submitting report...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsHistory(BuildContext context, UserReportsLoaded state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Report History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  context.read<ReportBloc>().add(const ReportCategoriesRequested());
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: state.reports.isEmpty
              ? const Center(
                  child: Text(
                    'No reports submitted yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: state.reports.length,
                  itemBuilder: (context, index) {
                    final report = state.reports[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: Icon(
                          _getIncidentIcon(report.incidentType),
                          color: tPrimaryColor,
                        ),
                        title: Text(report.incidentType.replaceAll('_', ' ').toUpperCase()),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(report.location),
                            Text(
                              '${report.timestamp.day}/${report.timestamp.month}/${report.timestamp.year} '
                              '${report.timestamp.hour}:${report.timestamp.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(report.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            report.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: () {
                          _showReportDetails(context, report);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error: $message',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ReportBloc>().add(const ReportCategoriesRequested());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _submitReport(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to submit a report'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final recipientEmails = _recipientEmailController.text.isNotEmpty
          ? _recipientEmailController.text.split(',').map((e) => e.trim()).toList()
          : <String>[];

      final report = Report(
        id: '', // Will be generated by Firestore
        userId: user.uid,
        incidentType: _selectedIncidentType!,
        location: _locationController.text,
        description: _descriptionController.text,
        recipientEmails: recipientEmails,
        timestamp: DateTime.now(),
        status: 'pending',
      );

      context.read<ReportBloc>().add(ReportSubmissionRequested(report));
    }
  }

  void _clearForm() {
    _locationController.clear();
    _descriptionController.clear();
    _recipientEmailController.clear();
    setState(() {
      _selectedIncidentType = null;
    });
  }

  IconData _getIncidentIcon(String incidentType) {
    switch (incidentType) {
      case 'environmental_safety':
        return Icons.nature;
      case 'online_safety':
        return Icons.computer;
      case 'physical_safety':
        return Icons.health_and_safety;
      case 'suspicious_activity':
        return Icons.warning;
      default:
        return Icons.report;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showReportDetails(BuildContext context, Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Type: ${report.incidentType.replaceAll('_', ' ')}'),
              const SizedBox(height: 8),
              Text('Location: ${report.location}'),
              const SizedBox(height: 8),
              Text('Description: ${report.description}'),
              const SizedBox(height: 8),
              Text('Status: ${report.status}'),
              const SizedBox(height: 8),
              Text('Submitted: ${report.timestamp}'),
              if (report.submissionId != null) ...[
                const SizedBox(height: 8),
                Text('ID: ${report.submissionId}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
