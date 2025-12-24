import 'package:flutter/material.dart';
import 'package:guardiancare/core/core.dart';

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
        borderRadius: AppDimensions.borderRadiusL,
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: AppDimensions.dialogMaxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: AppDimensions.paddingAllL,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusL),
                  topRight: Radius.circular(AppDimensions.radiusL),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.language,
                    color: AppColors.white,
                    size: AppDimensions.iconL,
                  ),
                  SizedBox(width: AppDimensions.spaceM),
                  Expanded(
                    child: Text(
                      'Select Language',
                      style: AppTextStyles.h3.copyWith(color: AppColors.white),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.white),
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
                      style: TextStyle(fontSize: AppDimensions.iconXL),
                    ),
                    title: Text(
                      localeInfo.nativeName,
                      style: AppTextStyles.h3.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      localeInfo.name,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: AppDimensions.iconL,
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
