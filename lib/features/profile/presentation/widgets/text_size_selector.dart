import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/app/theme/tokens/text_scale_preset.dart';

/// Interactive reading-size selector ported from ezChat.
///
/// Displays four live `Aa` size options and an immediate live preview card
/// demonstrating hotel booking content scaled at the chosen preset.
class TextSizeSelector extends ConsumerWidget {
  const TextSizeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final activePreset = ref.watch(textScaleNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: shape.radiusSurface,
        border: Border.all(
          color: colors.borderSubtle,
          width: shape.borderDefault,
        ),
      ),
      padding: space.insetCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Text size',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 14.5,
              fontWeight: TypeScale.semiBold,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: space.stackText),
          Text(
            'Changes every screen in TRVLez.',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12.5,
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: space.stackItem),
          Row(
            spacing: space.inlineItem,
            children: [
              for (final preset in TextScalePreset.values)
                Expanded(
                  child: _TextSizeSampleTile(
                    preset: preset,
                    isSelected: preset == activePreset,
                    onTap: () {
                      ref
                          .read(textScaleNotifierProvider.notifier)
                          .setTextScalePreset(preset);
                    },
                  ),
                ),
            ],
          ),
          SizedBox(height: space.stackItem),
          _LivePreviewCard(scaleFactor: activePreset.scaleFactor),
        ],
      ),
    );
  }
}

class _TextSizeSampleTile extends StatelessWidget {
  const _TextSizeSampleTile({
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  final TextScalePreset preset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${preset.label} text size',
      child: InkWell(
        onTap: onTap,
        borderRadius: shape.radiusControl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            vertical: space.stackItem,
            horizontal: space.inlineMicro,
          ),
          decoration: BoxDecoration(
            color: isSelected ? colors.surfaceSubtle : colors.surface,
            borderRadius: shape.radiusControl,
            border: Border.all(
              color: isSelected ? colors.actionPrimary : colors.borderSubtle,
              width: isSelected ? 1.5 : shape.borderDefault,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Aa',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: preset.sampleSize,
                  fontWeight: TypeScale.bold,
                  color: isSelected ? colors.actionPrimary : colors.textPrimary,
                ),
              ),
              SizedBox(height: space.stackText),
              Text(
                preset.label,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11,
                  fontWeight: TypeScale.semiBold,
                  color: isSelected ? colors.actionPrimary : colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LivePreviewCard extends StatelessWidget {
  const _LivePreviewCard({required this.scaleFactor});

  final double scaleFactor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;

    return Container(
      width: double.infinity,
      padding: space.insetCard,
      decoration: BoxDecoration(
        color: colors.page,
        borderRadius: shape.radiusSurface,
        border: Border.all(
          color: colors.borderSubtle,
          width: shape.borderDefault,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PREVIEW',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 10.5 * scaleFactor,
              fontWeight: TypeScale.bold,
              letterSpacing: 0.8,
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: space.stackText),
          Text(
            'Grand Ocean Hotel',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 15.0 * scaleFactor,
              fontWeight: TypeScale.bold,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: space.stackText),
          Text(
            'Lisbon · 2–6 Nov · check-in from 3pm',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13.0 * scaleFactor,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
