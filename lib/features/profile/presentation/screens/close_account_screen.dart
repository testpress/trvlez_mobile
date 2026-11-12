import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
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
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

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
                    borderRadius: shape.radiusPill,
                    onTap: () => Navigator.maybePop(context),
                    child: Padding(
                      padding: EdgeInsets.all(space.stackItem),
                      child: Icon(
                        AppIcons.arrowLeft,
                        size: sizes.iconMd,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: space.inlineIconLabel),
                Text(
                  'Close my account',
                  style: context.text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // ── Content ────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: space.insetCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Choose what happens to your account. You can change your mind '
                    'about the first option; the second is permanent.',
                    style: context.text.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: space.stackFormField),

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
                  SizedBox(height: space.stackFormField),

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
                  SizedBox(height: space.stackFormField),

                  // Regulatory retention notice
                  Container(
                    padding: space.insetCard,
                    decoration: BoxDecoration(
                      color: colors.waitFill,
                      borderRadius: shape.radiusSurface,
                      border: Border.all(
                        color: colors.cardBorderSoft,
                        width: shape.borderDefault,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: shape.borderFocus),
                          child: Icon(
                            AppIcons.clock,
                            size: sizes.iconSm,
                            color: colors.waitInk,
                          ),
                        ),
                        SizedBox(width: space.inlineIconLabel),
                        Expanded(
                          child: Text(
                            'We are required by financial and travel regulations to keep '
                            'certain transaction records for up to 7 years. All other data '
                            'is erased immediately.',
                            style: context.text.labelMedium?.copyWith(
                              color: colors.waitInk,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: space.stackSection),
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
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Container(
      padding: space.insetCard,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: shape.radiusSurface,
        border: Border.all(
          color: colors.cardBorderSoft,
          width: shape.borderDefault,
        ),
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
                width: sizes.iconXl,
                height: sizes.iconXl,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDanger ? colors.redTint : colors.page,
                  borderRadius: shape.radiusControl,
                ),
                child: Icon(
                  icon,
                  size: sizes.iconSm,
                  color: isDanger ? colors.brandPrimary : colors.inkSecondary,
                ),
              ),
              SizedBox(width: space.inlineIconLabel),
              Expanded(
                child: Text(
                  title,
                  style: context.text.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDanger ? colors.brandPrimary : colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: space.stackItem),
          Text(
            body,
            style: context.text.labelMedium?.copyWith(
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: space.stackFormField),
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
                        borderRadius: shape.radiusPill,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: space.stackSection,
                        vertical: space.stackItem,
                      ),
                    ),
                    child: Text(
                      actionLabel,
                      style: context.text.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : OutlinedButton(
                    onPressed: onAction,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.textPrimary,
                      side: BorderSide(
                        color: colors.cardBorderSoft,
                        width: shape.borderDefault,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: shape.radiusPill,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: space.stackSection,
                        vertical: space.stackItem,
                      ),
                    ),
                    child: Text(
                      actionLabel,
                      style: context.text.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
