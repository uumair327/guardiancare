import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/features.dart';

class EmergencyContactPage extends StatelessWidget {
  const EmergencyContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
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
                      SizedBox(height: AppDimensions.spaceM),
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
                    padding: AppDimensions.paddingAllM,
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
                        SizedBox(height: AppDimensions.spaceL),
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
      elevation: AppDimensions.cardElevation,
      child: Padding(
        padding: AppDimensions.paddingAllM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: AppDimensions.iconXL,
                  color: AppColors.primary,
                ),
                SizedBox(width: AppDimensions.spaceM),
                Text(
                  title,
                  style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.spaceM),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: contacts
                  .map((contact) => Padding(
                        padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceXS),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<EmergencyBloc>().add(
                                  MakeCallRequested(contact['number']!),
                                );
                          },
                          icon: Icon(
                            Icons.phone,
                            size: AppDimensions.iconS,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            '${contact['name']}: ${contact['number']}',
                            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
                          ),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(
                                AppColors.surface),
                            padding:
                                WidgetStateProperty.all<EdgeInsetsGeometry>(
                                    EdgeInsets.symmetric(
                                        vertical: AppDimensions.spaceM, horizontal: AppDimensions.spaceM)),
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
