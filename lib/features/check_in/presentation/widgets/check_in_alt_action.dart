import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Half-width outlined pill action button on brand red surface.
class CheckInAltAction extends StatelessWidget {
  const CheckInAltAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: space.insetControlSm,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: colors.verificationOutlineButton,
              width: shape.borderMedium,
            ),
            borderRadius: shape.radiusPill,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: sizes.iconXs, color: colors.brandOnSurface),
              SizedBox(width: space.stackTight),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: TypeScale.semiBold,
                    color: colors.brandOnSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
