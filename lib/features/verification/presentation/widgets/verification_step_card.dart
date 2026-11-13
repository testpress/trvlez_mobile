import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Interactive progress card for a single step in the identity verification flow.
class VerificationStepCard extends StatelessWidget {
  const VerificationStepCard({
    super.key,
    required this.index,
    required this.isDone,
    required this.isActive,
    required this.stepData,
    this.onTap,
  });

  final int index;
  final bool isDone;
  final bool isActive;
  final ({IconData icon, String subtitle, String title, String route}) stepData;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final isLocked = !isActive && !isDone;

    final IconData icon = isDone
        ? AppIcons.check
        : (isLocked ? AppIcons.lock : stepData.icon);

    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      label: '${stepData.title}. ${stepData.subtitle}',
      child: Material(
        color: colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: shape.radiusSurface,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: space.insetCard,
            decoration: BoxDecoration(
              color: isActive
                  ? colors.verificationCardActiveFill
                  : colors.brandCardBackground,
              borderRadius: shape.radiusSurface,
              border: isActive
                  ? Border.all(
                      color: colors.brandOnSurface,
                      width: shape.borderMedium,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: sizes.avatarMd,
                  height: sizes.avatarMd,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isActive || isDone)
                        ? colors.brandOnSurface
                        : colors.verificationCardIconFill,
                  ),
                  child: Icon(
                    icon,
                    size: sizes.iconSm,
                    color: (isActive || isDone)
                        ? colors.brandPrimary
                        : colors.brandOnSurface,
                  ),
                ),
                SizedBox(width: space.inlineButtonGroup),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        stepData.title,
                        style: context.text.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isLocked
                              ? colors.verificationCardLockedTitle
                              : colors.brandOnSurface,
                        ),
                      ),
                      SizedBox(height: space.stackText),
                      Text(
                        stepData.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall?.copyWith(
                          color: isLocked
                              ? colors.verificationCardLockedSubtitle
                              : colors.brandSecondaryBody,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive) ...[
                  SizedBox(width: space.inlineMicro),
                  Icon(
                    AppIcons.chevronRight,
                    size: sizes.iconSm,
                    color: colors.brandOnSurface,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
