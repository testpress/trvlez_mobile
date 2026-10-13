import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';

/// Modal bottom sheet for inviting additional adult guests to verify for a booking.
class InviteGuestSheet extends StatefulWidget {
  const InviteGuestSheet({
    super.key,
    required this.reservationId,
    required this.bookingReference,
    this.adultIndex = 1,
    this.onInvited,
  });

  final String reservationId;
  final String bookingReference;
  final int adultIndex;
  final VoidCallback? onInvited;

  static Future<void> show(
    BuildContext context, {
    required String reservationId,
    required String bookingReference,
    int adultIndex = 1,
    VoidCallback? onInvited,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => InviteGuestSheet(
        reservationId: reservationId,
        bookingReference: bookingReference,
        adultIndex: adultIndex,
        onInvited: onInvited,
      ),
    );
  }

  @override
  State<InviteGuestSheet> createState() => _InviteGuestSheetState();
}

class _InviteGuestSheetState extends State<InviteGuestSheet> {
  bool _showingQrCode = false;
  bool _copied = false;

  String get _inviteUrl =>
      'https://trvlez.com/invite/${widget.bookingReference}?guest=${widget.adultIndex}';

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: _inviteUrl));
    setState(() => _copied = true);
    widget.onInvited?.call();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Grab handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: AppSpacing.sm + 1),
                decoration: BoxDecoration(
                  color: colors.line,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md - 2,
                AppSpacing.md,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _showingQrCode
                        ? 'Let them scan this'
                        : (widget.adultIndex > 1
                            ? 'Invite adult ${widget.adultIndex + 1}'
                            : 'Invite second guest'),
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 18,
                      fontWeight: TypeScale.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Each person verifies themselves on their own phone. You will not see their documents.',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      color: colors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  if (_showingQrCode) ...[
                    // QR Code panel
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: colors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: colors.borderDefault),
                        ),
                        child: SvgPicture.asset(
                          'assets/art/checkin_qr.svg',
                          width: 140,
                          height: 140,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: GestureDetector(
                        onTap: () => setState(() => _showingQrCode = false),
                        child: Text(
                          'Switch to sending a link',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13,
                            fontWeight: TypeScale.semiBold,
                            color: colors.brandPrimary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Link box
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm + 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: colors.borderDefault),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            AppIcons.paperclip,
                            size: 16,
                            color: colors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              _inviteUrl,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 12,
                                color: colors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          GestureDetector(
                            onTap: _copyLink,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm + 2,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _copied
                                    ? colors.statusSuccessBackground
                                    : colors.actionPrimary,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Text(
                                _copied ? 'Copied' : 'Copy',
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 11,
                                  fontWeight: TypeScale.bold,
                                  color: _copied
                                      ? colors.statusSuccessForeground
                                      : colors.textOnAction,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: GestureDetector(
                        onTap: () => setState(() => _showingQrCode = true),
                        child: Text(
                          'Or show a QR code for them to scan',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13,
                            fontWeight: TypeScale.semiBold,
                            color: colors.brandPrimary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'Done',
                    variant: AppButtonVariant.primary,
                    onPressed: () {
                      widget.onInvited?.call();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
