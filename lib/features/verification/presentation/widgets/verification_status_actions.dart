import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';

/// Primary action buttons on the verification status screen.
class VerificationStatusActions extends ConsumerWidget {
  final TravelerVerificationState state;

  const VerificationStatusActions({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    if (state.isFailed) {
      return Column(
        children: [
          ElevatedButton.icon(
            onPressed: () {
              ref.read(verificationNotifierProvider.notifier).reset();
              context.go(AppRoutes.passportCapture);
            },
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              'Re-submit Documents',
              style: AppTypography.label.copyWith(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.onSurface,
              foregroundColor: colorScheme.surface,
              minimumSize: Size(double.infinity, sizes.controlMd),
              shape: RoundedRectangleBorder(borderRadius: shape.radiusOverlay),
              elevation: 0,
            ),
          ),
          SizedBox(height: space.inlineButtonGroup),
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Support — coming soon!'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: shape.radiusControl,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.support_agent_rounded),
            label: Text(
              'Contact Support',
              style: AppTypography.label.copyWith(fontSize: 14),
            ),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurface.withValues(alpha: 0.7),
              minimumSize: Size(double.infinity, sizes.controlMd),
            ),
          ),
        ],
      );
    }

    if (state.isVerified) {
      return ElevatedButton.icon(
        onPressed: () {
          ref.invalidate(currentProfileProvider);
          ref.invalidate(verificationStatusProvider);
          ref.read(authNotifierProvider.notifier).refreshVerificationState();
          context.go(AppRoutes.home);
        },
        icon: const Icon(Icons.explore_rounded),
        label: Text(
          'Start Exploring',
          style: AppTypography.label.copyWith(fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.onSurface,
          foregroundColor: colorScheme.surface,
          minimumSize: Size(double.infinity, sizes.controlMd),
          shape: RoundedRectangleBorder(borderRadius: shape.radiusOverlay),
          elevation: 0,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
