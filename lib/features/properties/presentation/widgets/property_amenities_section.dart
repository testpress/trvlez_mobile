import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';

/// Displays horizontal pills of property amenities and facilities.
class PropertyAmenitiesSection extends StatelessWidget {
  final List<String> facilities;

  const PropertyAmenitiesSection({super.key, required this.facilities});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Facilities & Amenities',
          style: AppTypography.heading.copyWith(
            fontSize: 18,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: facilities
                .map(
                  (f) => _FacilityPill(
                    icon: _getFacilityIcon(f),
                    label: _formatFacilityLabel(f),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  static IconData _getFacilityIcon(String facility) {
    final f = facility.toLowerCase();
    if (f.contains('wifi') || f.contains('internet')) return Icons.wifi;
    if (f.contains('pool') || f.contains('swim')) return Icons.pool;
    if (f.contains('spa') || f.contains('wellness') || f.contains('massage')) {
      return Icons.spa;
    }
    if (f.contains('park')) return Icons.local_parking;
    if (f.contains('restaurant') ||
        f.contains('dining') ||
        f.contains('food') ||
        f.contains('dinner')) {
      return Icons.restaurant;
    }
    if (f.contains('gym') || f.contains('fitness')) {
      return Icons.fitness_center;
    }
    if (f.contains('bar') || f.contains('drink') || f.contains('cocktail')) {
      return Icons.local_bar;
    }
    if (f.contains('ac') || f.contains('air')) return Icons.ac_unit;
    if (f.contains('heat')) return Icons.thermostat;
    if (f.contains('breakfast') || f.contains('coffee')) {
      return Icons.free_breakfast;
    }
    if (f.contains('room service')) return Icons.room_service;
    if (f.contains('beach') || f.contains('ocean') || f.contains('sea')) {
      return Icons.beach_access;
    }
    if (f.contains('mountain') || f.contains('hill') || f.contains('view')) {
      return Icons.landscape;
    }
    if (f.contains('tub') || f.contains('bath') || f.contains('jacuzzi')) {
      return Icons.hot_tub;
    }
    if (f.contains('tv') || f.contains('television')) return Icons.tv;
    if (f.contains('balcony') || f.contains('terrace')) return Icons.balcony;
    return Icons.check_circle_outline;
  }

  static String _formatFacilityLabel(String facility) {
    return facility
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }
}

class _FacilityPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FacilityPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        borderRadius: AppRadius.input,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colors.actionPrimary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.body.copyWith(
              color: colors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Backwards-compatibility alias
typedef PropertyFacilitiesSection = PropertyAmenitiesSection;
