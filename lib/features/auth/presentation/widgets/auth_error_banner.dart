import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Reusable dismissible error banner for authentication screens.
class AuthErrorBanner extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onDismiss;

  const AuthErrorBanner({
    super.key,
    required this.errorMessage,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null || errorMessage!.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Padding(
      padding: EdgeInsets.only(bottom: space.stackFormField),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          padding: space.insetControlMd,
          decoration: BoxDecoration(
            color: colors.brandCardBackground,
            borderRadius: shape.radiusControl,
            border: Border.all(
              color: colors.brandButtonDisabledBackground,
              width: shape.borderDefault,
            ),
          ),
          child: Row(
            children: [
              Icon(
                AppIcons.alertCircle,
                color: colors.brandSecondary,
                size: sizes.iconSm,
              ),
              SizedBox(width: space.inlineIconLabel),
              Expanded(
                child: Text(
                  errorMessage!,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    fontWeight: TypeScale.regular,
                  ).copyWith(color: colors.brandOnSurface),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: space.inlineMicro),
              Semantics(
                button: true,
                label: 'Dismiss error',
                child: InkWell(
                  onTap: onDismiss,
                  borderRadius: shape.radiusControl,
                  child: Padding(
                    padding: EdgeInsets.all(space.inlineMicro),
                    child: Icon(
                      AppIcons.close,
                      color: colors.brandSecondarySmall,
                      size: sizes.iconSm,
                    ),
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
