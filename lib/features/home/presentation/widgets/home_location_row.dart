import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Location selector row displaying current city and opening the location sheet.
class HomeLocationRow extends StatelessWidget {
  const HomeLocationRow({super.key, required this.location, this.onTap});

  final String location;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      label: 'Selected location: $location',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(AppIcons.mapPinFilled, size: 14, color: colors.brandPrimary),
              const SizedBox(width: 6),
              Text(
                location,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 13,
                  fontWeight: TypeScale.medium,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(AppIcons.chevronDown, size: 13, color: colors.brandPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
