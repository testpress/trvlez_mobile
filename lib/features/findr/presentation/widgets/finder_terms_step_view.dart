import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/status_pill.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/finder_terms.dart';

/// Step 1 view: Versioned Findr Terms and Conditions of Participation.
class FinderTermsStepView extends StatelessWidget {
  const FinderTermsStepView({
    super.key,
    required this.terms,
    required this.hasAcceptedTerms,
    required this.onAcceptanceChanged,
    this.showHeaderPills = false,
  });

  final FinderTerms terms;
  final bool hasAcceptedTerms;
  final ValueChanged<bool> onAcceptanceChanged;
  final bool showHeaderPills;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: sizes.containerForm),
        child: ListView(
          padding: space.insetCard,
          children: [
            if (showHeaderPills) ...[
              Row(
                children: [
                  const StatusPill(
                    label: 'Step 1 of 2',
                    state: StatusPillState.awaiting,
                  ),
                  SizedBox(width: space.inlineItem),
                  Expanded(
                    child: Text(
                      'Participation Agreement',
                      style: context.text.labelMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: space.inlineItem),
                  StatusPill(
                    label: terms.version,
                    state: StatusPillState.completed,
                  ),
                ],
              ),
              SizedBox(height: space.stackItem),
            ],

            Text(
              terms.title,
              style: context.text.titleLarge?.copyWith(
                color: colors.textPrimary,
                fontWeight: TypeScale.bold,
              ),
            ),
            SizedBox(height: space.stackText),
            Text(
              terms.summary,
              style: context.text.bodyMedium?.copyWith(
                color: colors.textSecondary,
                height: 1.45,
              ),
            ),
            SizedBox(height: space.stackItem),

            // Section Cards
            for (final section in terms.sections)
              Container(
                margin: EdgeInsets.only(bottom: space.stackItem),
                padding: space.insetCard,
                decoration: BoxDecoration(
                  color: colors.surface,
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
                      section.title,
                      style: context.text.titleSmall?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: TypeScale.bold,
                      ),
                    ),
                    SizedBox(height: space.stackTight),
                    Text(
                      section.content,
                      style: context.text.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: space.stackTight),

            // Checkbox Tile
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onAcceptanceChanged(!hasAcceptedTerms),
                borderRadius: shape.radiusSurface,
                child: Container(
                  padding: space.insetCard,
                  decoration: BoxDecoration(
                    color: hasAcceptedTerms
                        ? colors.brandPrimary.withAlpha(20)
                        : colors.surfaceSubtle,
                    borderRadius: shape.radiusSurface,
                    border: Border.all(
                      color: hasAcceptedTerms
                          ? colors.brandPrimary
                          : colors.borderSubtle,
                      width: shape.borderDefault,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: hasAcceptedTerms,
                        onChanged: (checked) {
                          onAcceptanceChanged(checked ?? false);
                        },
                        activeColor: colors.brandPrimary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: shape.radiusControlSm,
                        ),
                      ),
                      SizedBox(width: space.inlineItem),
                      Expanded(
                        child: Text(
                          'I have read, understood, and accept the Findr Programme Participation Terms and Conditions (${terms.version}).',
                          style: context.text.bodySmall?.copyWith(
                            color: colors.textPrimary,
                            fontWeight: TypeScale.medium,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
