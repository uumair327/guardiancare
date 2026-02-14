import 'package:flutter/material.dart';
import 'package:guardiancare/core/core.dart';

/// Dialog for selecting app language
/// Clean, user-friendly UI following Material Design
class LanguageSelectorDialog extends StatelessWidget {

  const LanguageSelectorDialog({
    super.key,
    required this.currentLocale,
    required this.onLocaleSelected,
  });
  final Locale? currentLocale;
  final Function(Locale) onLocaleSelected;

  @override
  Widget build(BuildContext context) {
    final supportedLocales = LocaleService.getSupportedLocales();

    return Dialog(
      backgroundColor: context.colors.surface,
      surfaceTintColor: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusL,
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: AppDimensions.dialogMaxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: AppDimensions.paddingAllL,
              decoration: BoxDecoration(
                color: context.colors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusL),
                  topRight: Radius.circular(AppDimensions.radiusL),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.language,
                    color: AppColors.white,
                    size: AppDimensions.iconL,
                  ),
                  const SizedBox(width: AppDimensions.spaceM),
                  Expanded(
                    child: Text(
                      'Select Language',
                      style: AppTextStyles.h3.copyWith(color: AppColors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.white),
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
                      style: const TextStyle(fontSize: AppDimensions.iconXL),
                    ),
                    title: Text(
                      localeInfo.nativeName,
                      style: AppTextStyles.h3.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? context.colors.primary
                            : context.colors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      localeInfo.name,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected
                            ? context.colors.primary
                            : context.colors.textSecondary,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: context.colors.primary,
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
