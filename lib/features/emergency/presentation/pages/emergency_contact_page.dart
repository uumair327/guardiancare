import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/di/injection_container.dart';
import 'package:guardiancare/features/emergency/presentation/bloc/emergency_bloc.dart';
import 'package:guardiancare/features/emergency/presentation/bloc/emergency_event.dart';
import 'package:guardiancare/features/emergency/presentation/bloc/emergency_state.dart';
import 'package:guardiancare/core/constants/app_colors.dart';
import 'package:guardiancare/core/l10n/generated/app_localizations.dart';

class EmergencyContactPage extends StatelessWidget {
  const EmergencyContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return BlocProvider(
      create: (context) => sl<EmergencyBloc>()..add(LoadEmergencyContacts()),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.emergencyContact),
          ),
          body: BlocConsumer<EmergencyBloc, EmergencyState>(
            listener: (context, state) {
              if (state is EmergencyError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              if (state is EmergencyLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is EmergencyError && state is! EmergencyContactsLoaded) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.errorPrefix(state.message)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<EmergencyBloc>()
                              .add(LoadEmergencyContacts());
                        },
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                );
              }

              if (state is EmergencyContactsLoaded) {
                final emergencyServices =
                    state.getContactsByCategory('Emergency Services');
                final childSafety = state.getContactsByCategory('Child Safety');

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (emergencyServices.isNotEmpty)
                          _buildCard(
                            context: context,
                            icon: Icons.medical_services,
                            title: l10n.emergencyServices,
                            contacts: emergencyServices
                                .map((c) => {'name': c.name, 'number': c.number})
                                .toList(),
                          ),
                        const SizedBox(height: 20),
                        if (childSafety.isNotEmpty)
                          _buildCard(
                            context: context,
                            icon: Icons.child_care,
                            title: l10n.childSafety,
                            contacts: childSafety
                                .map((c) => {'name': c.name, 'number': c.number})
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                );
              }

              return Center(child: Text(l10n.loadingEmergencyContacts));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required List<Map<String, String>> contacts,
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
                            context.read<EmergencyBloc>().add(
                                  MakeCallRequested(contact['number']!),
                                );
                          },
                          icon: const Icon(
                            Icons.phone,
                            size: 20,
                            color: tPrimaryColor,
                          ),
                          label: Text(
                            '${contact['name']}: ${contact['number']}',
                            style: const TextStyle(
                                fontSize: 16, color: tTextPrimary),
                          ),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(
                                Colors.white),
                            padding:
                                WidgetStateProperty.all<EdgeInsetsGeometry>(
                                    const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 15)),
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
}
