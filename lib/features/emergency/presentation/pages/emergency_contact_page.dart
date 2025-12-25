import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/features.dart';

/// Page that displays emergency contacts organized by category.
/// 
/// This page composes EmergencyContactCard widgets without containing
/// complex build logic, following the Single Responsibility Principle.
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
                return _buildErrorState(context, l10n, state.message);
              }

              if (state is EmergencyContactsLoaded) {
                return _buildContactsList(context, l10n, state);
              }

              return Center(child: Text(l10n.loadingEmergencyContacts));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, AppLocalizations l10n, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l10n.errorPrefix(message)),
          SizedBox(height: AppDimensions.spaceM),
          ElevatedButton(
            onPressed: () {
              context.read<EmergencyBloc>().add(LoadEmergencyContacts());
            },
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList(
    BuildContext context,
    AppLocalizations l10n,
    EmergencyContactsLoaded state,
  ) {
    final emergencyServices = state.getContactsByCategory('Emergency Services');
    final childSafety = state.getContactsByCategory('Child Safety');

    return SingleChildScrollView(
      child: Padding(
        padding: AppDimensions.paddingAllM,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (emergencyServices.isNotEmpty)
              EmergencyContactCard(
                icon: Icons.medical_services,
                title: l10n.emergencyServices,
                contacts: emergencyServices,
                onCall: (number) => _handleCall(context, number),
              ),
            SizedBox(height: AppDimensions.spaceL),
            if (childSafety.isNotEmpty)
              EmergencyContactCard(
                icon: Icons.child_care,
                title: l10n.childSafety,
                contacts: childSafety,
                onCall: (number) => _handleCall(context, number),
              ),
          ],
        ),
      ),
    );
  }

  void _handleCall(BuildContext context, String number) {
    context.read<EmergencyBloc>().add(MakeCallRequested(number));
  }
}
