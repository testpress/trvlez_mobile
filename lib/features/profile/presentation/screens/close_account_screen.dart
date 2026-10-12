import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_pinned_header.dart';

/// Screen allowing travelers to either deactivate or permanently erase their account.
class CloseAccountScreen extends StatelessWidget {
  const CloseAccountScreen({super.key});

  void _notWired(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$action requires confirmation and is disabled in this preview.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.page,
      body: Column(
        children: [
          // ── Pinned Header ──────────────────────────────────────────────
          AppPinnedHeader(
            child: Row(
              children: [
                Semantics(
                  button: true,
                  label: 'Back',
                  child: InkWell(
                    borderRadius: AppRadius.fullRadius,
                    onTap: () => Navigator.maybePop(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        AppIcons.arrowLeft,
                        size: 20,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Close my account',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 18,
                    fontWeight: TypeScale.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // ── Content ────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Choose what happens to your account. You can change your mind '
                    'about the first option; the second is permanent.',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13,
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Option 1: Deactivate
                  _CloseAccountOptionCard(
                    icon: AppIcons.playerPause,
                    title: 'Deactivate',
                    body:
                        'Your account is hidden and you stop receiving anything '
                        'from us. Your bookings and verification stay intact. Sign '
                        'in any time to bring it back.',
                    actionLabel: 'Deactivate',
                    isDanger: false,
                    onAction: () => _notWired(context, 'Deactivating'),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Option 2: Close and delete
                  _CloseAccountOptionCard(
                    icon: AppIcons.trash,
                    title: 'Close and delete my data',
                    body:
                        'Your account closes and we erase everything we are '
                        'permitted to erase, including your documents. This cannot '
                        'be undone.',
                    actionLabel: 'Close and delete',
                    isDanger: true,
                    onAction: () => _notWired(context, 'Deleting account'),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Regulatory retention notice
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.waitFill,
                      borderRadius: AppRadius.cardRadius,
                      border: Border.all(color: colors.cardBorderSoft),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            AppIcons.clock,
                            size: 16,
                            color: colors.waitInk,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'We are required by financial and travel regulations to keep '
                            'certain transaction records for up to 7 years. All other data '
                            'is erased immediately.',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 12,
                              color: colors.waitInk,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CloseAccountOptionCard extends StatelessWidget {
  const _CloseAccountOptionCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.isDanger,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final bool isDanger;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: colors.cardBorderSoft),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDanger ? colors.redTint : colors.page,
                  borderRadius: AppRadius.mdRadius,
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: isDanger ? colors.brandPrimary : colors.inkSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14,
                    fontWeight: TypeScale.bold,
                    color: isDanger ? colors.brandPrimary : colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: isDanger
                ? ElevatedButton(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.brandPrimary,
                      foregroundColor: colors.textOnAction,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.fullRadius,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    child: Text(
                      actionLabel,
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: TypeScale.bold,
                      ),
                    ),
                  )
                : OutlinedButton(
                    onPressed: onAction,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.textPrimary,
                      side: BorderSide(color: colors.cardBorderSoft),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.fullRadius,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    child: Text(
                      actionLabel,
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: TypeScale.bold,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
