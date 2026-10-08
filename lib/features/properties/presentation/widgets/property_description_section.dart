import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';

/// Expandable property description section.
class PropertyDescriptionSection extends StatefulWidget {
  final String description;

  const PropertyDescriptionSection({super.key, required this.description});

  @override
  State<PropertyDescriptionSection> createState() =>
      _PropertyDescriptionSectionState();
}

class _PropertyDescriptionSectionState
    extends State<PropertyDescriptionSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = widget.description.isNotEmpty
        ? widget.description
        : 'Experience premier hospitality, comfortable rooms, and dedicated service during your stay.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Property',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          text,
          maxLines: _isExpanded ? null : 3,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: GoogleFonts.cabin(
            fontSize: 14,
            color: colors.textSecondary,
            height: 1.5,
          ),
        ),
        if (text.length > 100) ...[
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Text(
              _isExpanded ? 'Show less' : 'Read more',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colors.actionPrimary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
