import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
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
    final shape = context.shape;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: shape.radiusOverlay.topLeft,
          topRight: shape.radiusOverlay.topRight,
        ),
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
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

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
                width: sizes.avatarMd,
                height: space.stackText,
                margin: EdgeInsets.only(top: space.stackItem),
                decoration: BoxDecoration(
                  color: colors.line,
                  borderRadius: shape.radiusPill,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                space.stackFormField,
                space.stackFormField,
                space.stackFormField,
                space.stackSection,
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
                  SizedBox(height: space.stackText),
                  Text(
                    'Each person verifies themselves on their own phone. You will not see their documents.',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      color: colors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: space.stackFormField),

                  if (_showingQrCode) ...[
                    // QR Code panel
                    Center(
                      child: Container(
                        padding: space.insetCard,
                        decoration: BoxDecoration(
                          color: colors.surfaceSubtle,
                          borderRadius: shape.radiusControl,
                          border: Border.all(
                            color: colors.borderDefault,
                            width: shape.borderDefault,
                          ),
                        ),
                        child: SvgPicture.asset(
                          'assets/art/checkin_qr.svg',
                          width: sizes.thumbPhotoMd,
                          height: sizes.thumbPhotoMd,
                        ),
                      ),
                    ),
                    SizedBox(height: space.stackFormField),
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
                      padding: space.insetControlMd,
                      decoration: BoxDecoration(
                        color: colors.surfaceSubtle,
                        borderRadius: shape.radiusControl,
                        border: Border.all(
                          color: colors.borderDefault,
                          width: shape.borderDefault,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            AppIcons.paperclip,
                            size: sizes.iconSm,
                            color: colors.textSecondary,
                          ),
                          SizedBox(width: space.inlineIconLabel),
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
                          SizedBox(width: space.inlineIconLabel),
                          GestureDetector(
                            onTap: _copyLink,
                            child: Container(
                              padding: space.insetTag,
                              decoration: BoxDecoration(
                                color: _copied
                                    ? colors.statusSuccessBackground
                                    : colors.actionPrimary,
                                borderRadius: shape.radiusPill,
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
                    SizedBox(height: space.stackFormField),
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

                  SizedBox(height: space.stackSection),
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
