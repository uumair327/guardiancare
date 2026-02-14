import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/home/presentation/widgets/action_card.dart';

/// Action Grid with staggered animations
/// 
/// Features:
/// - Staggered entrance animations
/// - 3D card effects
/// - Responsive grid layout
/// - Performance optimized
class ActionGrid extends StatefulWidget {

  const ActionGrid({
    super.key,
    required this.onQuizTap,
    required this.onLearnTap,
    required this.onEmergencyTap,
    required this.onProfileTap,
    required this.onWebsiteTap,
    required this.onMailTap,
  });
  final VoidCallback onQuizTap;
  final VoidCallback onLearnTap;
  final VoidCallback onEmergencyTap;
  final VoidCallback onProfileTap;
  final VoidCallback onWebsiteTap;
  final VoidCallback onMailTap;

  @override
  State<ActionGrid> createState() => _ActionGridState();
}

class _ActionGridState extends State<ActionGrid> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final actions = [
      _ActionItem(
        icon: Icons.quiz_rounded,
        label: l10n.quiz,
        color: AppColors.primary,
        onTap: widget.onQuizTap,
      ),
      _ActionItem(
        icon: Icons.video_library_rounded,
        label: l10n.learn,
        color: AppColors.secondary,
        onTap: widget.onLearnTap,
      ),
      _ActionItem(
        icon: Icons.emergency_rounded,
        label: l10n.emergency,
        color: AppColors.error,
        onTap: widget.onEmergencyTap,
      ),
      _ActionItem(
        icon: Icons.person_rounded,
        label: l10n.profile,
        color: AppColors.accent,
        onTap: widget.onProfileTap,
      ),
      _ActionItem(
        icon: CupertinoIcons.globe,
        label: l10n.website,
        color: AppColors.info,
        onTap: widget.onWebsiteTap,
      ),
      _ActionItem(
        icon: Icons.email_rounded,
        label: l10n.mailUs,
        color: AppColors.warning,
        onTap: widget.onMailTap,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: AppDimensions.spaceM,
          crossAxisSpacing: AppDimensions.spaceM,
          childAspectRatio: 0.85,
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          // Calculate stagger delay based on grid position
          final row = index ~/ 3;
          final col = index % 3;
          final staggerIndex = row + col;

          return FadeSlideWidget(
            duration: AppDurations.animationMedium,
            delay: Duration(milliseconds: 80 * staggerIndex),
            slideOffset: 20,
            child: ActionCard(
              icon: action.icon,
              label: action.label,
              color: action.color,
              onTap: action.onTap,
            ),
          );
        },
      ),
    );
  }
}

class _ActionItem {

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}
