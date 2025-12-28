import 'package:guardiancare/core/constants/constants.dart';
import 'package:guardiancare/core/error/exceptions.dart';
import 'package:guardiancare/features/emergency/data/models/emergency_contact_model.dart';
import 'package:url_launcher/url_launcher.dart';

/// Local data source for emergency operations
abstract class EmergencyLocalDataSource {
  /// Get all emergency contacts
  Future<List<EmergencyContactModel>> getEmergencyContacts();

  /// Get emergency contacts by category
  Future<List<EmergencyContactModel>> getContactsByCategory(String category);

  /// Make a phone call
  Future<void> makePhoneCall(String phoneNumber);
}

class EmergencyLocalDataSourceImpl implements EmergencyLocalDataSource {
  // Predefined emergency contacts
  static const List<Map<String, String>> _emergencyServices = [
    {'name': 'Police', 'number': '100', 'category': 'Emergency Services'},
    {
      'name': 'Child Helpline',
      'number': '1098',
      'category': 'Emergency Services'
    },
  ];

  static const List<Map<String, String>> _childSafety = [
    {
      'name': 'Children of India Coordination Office',
      'number': '+91 94824 50000',
      'category': 'Child Safety'
    },
    {
      'name': 'National Center for Missing & Exploited Children',
      'number': '+1-800-843-5678',
      'category': 'Child Safety'
    },
    {
      'name': 'Childhelp National Child Abuse Hotline',
      'number': '+91 80042 24453',
      'category': 'Child Safety'
    },
  ];

  @override
  Future<List<EmergencyContactModel>> getEmergencyContacts() async {
    try {
      final allContacts = [..._emergencyServices, ..._childSafety];
      return allContacts
          .map((contact) => EmergencyContactModel.fromJson(contact))
          .toList();
    } catch (e) {
      throw CacheException(ErrorStrings.withDetails(ErrorStrings.getEmergencyContactsError, e.toString()));
    }
  }

  @override
  Future<List<EmergencyContactModel>> getContactsByCategory(
      String category) async {
    try {
      List<Map<String, String>> contacts;

      if (category.toLowerCase() == 'emergency services') {
        contacts = _emergencyServices;
      } else if (category.toLowerCase() == 'child safety') {
        contacts = _childSafety;
      } else {
        contacts = [];
      }

      return contacts
          .map((contact) => EmergencyContactModel.fromJson(contact))
          .toList();
    } catch (e) {
      throw CacheException(
          ErrorStrings.withDetails(ErrorStrings.getContactsByCategoryError, e.toString()));
    }
  }

  @override
  Future<void> makePhoneCall(String phoneNumber) async {
    try {
      // Remove spaces and special characters except + and digits
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final Uri phoneLaunchUri = Uri(scheme: 'tel', path: cleanNumber);

      print('Attempting to launch phone dialer for: $cleanNumber');
      
      // Try to launch with mode platformDefault first
      final bool launched = await launchUrl(
        phoneLaunchUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw CacheException(ErrorStrings.withDetails(ErrorStrings.phoneDialerError, phoneNumber));
      }
    } catch (e) {
      print('Error making phone call: $e');
      throw CacheException(ErrorStrings.withDetails(ErrorStrings.makePhoneCallError, e.toString()));
    }
  }
}
