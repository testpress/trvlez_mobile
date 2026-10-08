import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';

/// Top section displaying property name, location, and operational highlights.
class PropertyOverviewSection extends StatelessWidget {
  final Property property;

  const PropertyOverviewSection({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                property.name,
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
            ),
            if (property.propertyType != null &&
                property.propertyType!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.actionPrimary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.smRadius,
                ),
                child: Text(
                  property.propertyType!.toUpperCase(),
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.actionPrimary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 16,
              color: colors.actionPrimary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                property.locationString.isNotEmpty
                    ? property.locationString
                    : 'Location details upon booking',
                style: GoogleFonts.cabin(
                  fontSize: 14,
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        if (property.checkinTime != null || property.checkoutTime != null) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (property.checkinTime != null)
                _InfoBadge(
                  icon: Icons.login,
                  label: 'Check-in: ${property.checkinTime}',
                ),
              if (property.checkoutTime != null)
                _InfoBadge(
                  icon: Icons.logout,
                  label: 'Check-out: ${property.checkoutTime}',
                ),
              if (property.totalRooms != null && property.totalRooms! > 0)
                _InfoBadge(
                  icon: Icons.meeting_room_outlined,
                  label: '${property.totalRooms} Rooms',
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        borderRadius: AppRadius.smRadius,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.actionPrimary),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.cabin(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
