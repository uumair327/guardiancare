import 'package:flutter/material.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/emergency/domain/entities/emergency_contact_entity.dart';

/// A card widget that displays a list of emergency contacts with call functionality.
/// 
/// This widget extracts the card rendering logic from EmergencyContactPage
/// to follow the Single Responsibility Principle.
class EmergencyContactCard extends StatelessWidget {
  /// The icon to display in the card header
  final IconData icon;
  
  /// The title of the card (e.g., "Emergency Services", "Child Safety")
  final String title;
  
  /// The list of emergency contacts to display
  final List<EmergencyContactEntity> contacts;
  
  /// Callback function when a contact's call button is pressed
  final void Function(String number) onCall;

  const EmergencyContactCard({
    super.key,
    required this.icon,
    required this.title,
    required this.contacts,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.cardElevation,
      child: Padding(
        padding: AppDimensions.paddingAllM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: AppDimensions.spaceM),
            _buildContactList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
    );
  }

  Widget _buildContactList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contacts
          .map((contact) => _buildContactButton(contact))
          .toList(),
    );
  }

  Widget _buildContactButton(EmergencyContactEntity contact) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceXS),
      child: ElevatedButton.icon(
        onPressed: () => onCall(contact.number),
        icon: Icon(
          Icons.phone,
          size: AppDimensions.iconS,
          color: AppColors.primary,
        ),
        label: Text(
          '${contact.name}: ${contact.number}',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
        ),
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(AppColors.surface),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(
              vertical: AppDimensions.spaceM,
              horizontal: AppDimensions.spaceM,
            ),
          ),
        ),
      ),
    );
  }
}
