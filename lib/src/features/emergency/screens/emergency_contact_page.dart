import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/core/di/dependency_injection.dart';
import '../bloc/emergency_bloc.dart';
import '../bloc/emergency_event.dart';
import '../bloc/emergency_state.dart';

class EmergencyContactPage extends StatelessWidget {
  const EmergencyContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DependencyInjection.get<EmergencyBloc>()
        ..add(const EmergencyContactsRequested()),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Emergency Contact'),
            actions: [
              BlocBuilder<EmergencyBloc, EmergencyState>(
                builder: (context, state) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    return IconButton(
                      icon: const Icon(Icons.history),
                      onPressed: () {
                        context.read<EmergencyBloc>().add(
                          EmergencyReportsRequested(user.uid),
                        );
                      },
                      tooltip: 'View Call History',
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          body: BlocConsumer<EmergencyBloc, EmergencyState>(
            listener: (context, state) {
              if (state is EmergencyCallCompleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Called ${state.contactName} (${state.phoneNumber})'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is EmergencyError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is EmergencyLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is EmergencyContactsLoaded) {
                return _buildContactsList(context, state);
              } else if (state is EmergencyCallInProgress) {
                return _buildCallInProgress(state.contactId);
              } else if (state is EmergencyReportsLoaded) {
                return _buildReportsView(context, state);
              } else if (state is EmergencyError) {
                return _buildErrorState(context, state.message);
              }
              
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContactsList(BuildContext context, EmergencyContactsLoaded state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: state.contactsByCategory.entries.map((entry) {
            final category = entry.key;
            final contacts = entry.value;
            
            IconData icon;
            switch (category) {
              case 'Emergency Services':
                icon = Icons.medical_services;
                break;
              case 'Child Safety':
                icon = Icons.child_care;
                break;
              default:
                icon = Icons.phone;
            }
            
            return Column(
              children: [
                _buildCard(
                  context: context,
                  icon: icon,
                  title: category,
                  contacts: contacts,
                ),
                const SizedBox(height: 20),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required List contacts,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: tPrimaryColor,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: contacts
                  .map((contact) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              context.read<EmergencyBloc>().add(
                                EmergencyCallRequested(contact.id, user.uid),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.phone,
                            size: 20,
                            color: tPrimaryColor,
                          ),
                          label: Text(
                            '${contact.name}: ${contact.phoneNumber}',
                            style: const TextStyle(
                                fontSize: 16, color: tTextPrimary),
                          ),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                            padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                                const EdgeInsets.symmetric(vertical: 10, horizontal: 15)),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallInProgress(String contactId) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Initiating emergency call...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsView(BuildContext context, EmergencyReportsLoaded state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Emergency Call History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  context.read<EmergencyBloc>().add(const EmergencyContactsRequested());
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: state.reports.isEmpty
              ? const Center(
                  child: Text(
                    'No emergency calls recorded',
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
                        leading: const Icon(Icons.phone, color: tPrimaryColor),
                        title: Text(report.contactName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(report.phoneNumber),
                            Text(
                              '${report.timestamp.day}/${report.timestamp.month}/${report.timestamp.year} '
                              '${report.timestamp.hour}:${report.timestamp.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: Text(
                          report.status.toUpperCase(),
                          style: TextStyle(
                            color: report.status == 'called' ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
              context.read<EmergencyBloc>().add(const EmergencyContactsRequested());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
