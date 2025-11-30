import 'package:flutter/material.dart';
import 'package:guardiancare/core/services/locale_service.dart';
import 'package:guardiancare/core/constants/app_colors.dart';

/// Dialog for selecting app language
/// Clean, user-friendly UI following Material Design
class LanguageSelectorDialog extends StatelessWidget {
  final Locale? currentLocale;
  final Function(Locale) onLocaleSelected;

  const LanguageSelectorDialog({
    super.key,
    required this.currentLocale,
    required this.onLocaleSelected,
  });

  @override
  Widget build(BuildContext context) {
    final supportedLocales = LocaleService.getSupportedLocales();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: tPrimaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.language,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Select Language',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Language list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: supportedLocales.length,
                itemBuilder: (context, index) {
                  final localeInfo = supportedLocales[index];
                  final isSelected = currentLocale?.languageCode ==
                      localeInfo.locale.languageCode;

                  return ListTile(
                    leading: Text(
                      localeInfo.flag,
                      style: const TextStyle(fontSize: 32),
                    ),
                    title: Text(
                      localeInfo.nativeName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? tPrimaryColor : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      localeInfo.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? tPrimaryColor : Colors.black54,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: tPrimaryColor,
                            size: 28,
                          )
                        : null,
                    onTap: () {
                      onLocaleSelected(localeInfo.locale);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show the language selector dialog
  static Future<void> show(
    BuildContext context, {
    required Locale? currentLocale,
    required Function(Locale) onLocaleSelected,
  }) {
    return showDialog(
      context: context,
      builder: (context) => LanguageSelectorDialog(
        currentLocale: currentLocale,
        onLocaleSelected: onLocaleSelected,
      ),
    );
  }
}
