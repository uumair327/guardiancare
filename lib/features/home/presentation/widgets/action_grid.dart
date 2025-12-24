import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/home/home.dart';

class ActionGrid extends StatelessWidget {
  final VoidCallback onQuizTap;
  final VoidCallback onLearnTap;
  final VoidCallback onEmergencyTap;
  final VoidCallback onProfileTap;
  final VoidCallback onWebsiteTap;
  final VoidCallback onMailTap;

  const ActionGrid({
    super.key,
    required this.onQuizTap,
    required this.onLearnTap,
    required this.onEmergencyTap,
    required this.onProfileTap,
    required this.onWebsiteTap,
    required this.onMailTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppDimensions.spaceM,
        crossAxisSpacing: AppDimensions.spaceM,
        childAspectRatio: 0.85,
        children: [
          ActionCard(
            icon: Icons.quiz,
            label: l10n.quiz,
            color: AppColors.primary,
            onTap: onQuizTap,
          ),
          ActionCard(
            icon: Icons.video_library,
            label: l10n.learn,
            color: AppColors.secondary,
            onTap: onLearnTap,
          ),
          ActionCard(
            icon: Icons.emergency,
            label: l10n.emergency,
            color: AppColors.error,
            onTap: onEmergencyTap,
          ),
          ActionCard(
            icon: Icons.person,
            label: l10n.profile,
            color: AppColors.accent,
            onTap: onProfileTap,
          ),
          ActionCard(
            icon: CupertinoIcons.globe,
            label: l10n.website,
            color: AppColors.info,
            onTap: onWebsiteTap,
          ),
          ActionCard(
            icon: Icons.email,
            label: l10n.mailUs,
            color: AppColors.warning,
            onTap: onMailTap,
          ),
        ],
      ),
    );
  }
}
