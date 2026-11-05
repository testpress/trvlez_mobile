import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Card displaying the Finder's permanent traveler share code and native share actions.
class ReferTravelerCard extends StatelessWidget {
  const ReferTravelerCard({
    super.key,
    required this.shareCode,
    required this.shareUrl,
  });

  final String? shareCode;
  final String? shareUrl;

  void _copyToClipboard(BuildContext context) {
    final effectiveUrl = shareUrl ?? (shareCode != null ? 'https://trvlez.com/r/$shareCode' : '');
    if (effectiveUrl.isEmpty) return;

    Clipboard.setData(ClipboardData(text: effectiveUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Traveler referral link copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: context.colors.surface,
      ),
    );
  }

  Future<void> _shareLink() async {
    final effectiveUrl = shareUrl ?? (shareCode != null ? 'https://trvlez.com/r/$shareCode' : '');
    if (effectiveUrl.isEmpty) return;

    await SharePlus.instance.share(
      ShareParams(
        text: 'Book your next stay with verified ease on TrvlEz: $effectiveUrl',
        subject: 'Join me on TrvlEz',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    final code = shareCode;
    final hasCode = code != null && code.isNotEmpty;
    final displayCode = hasCode ? code : 'Loading...';

    return Container(
      padding: space.insetCard,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: shape.radiusControl,
        border: Border.all(
          color: colors.cardBorder,
          width: shape.borderDefault,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 4,
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
                width: sizes.avatarSm,
                height: sizes.avatarSm,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surfaceSubtle,
                  borderRadius: shape.radiusControlSm,
                ),
                child: Icon(
                  AppIcons.heart,
                  size: sizes.iconSm,
                  color: colors.brandPrimary,
                ),
              ),
              SizedBox(width: space.inlineIconLabel),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Refer a Traveler',
                      style: context.text.titleSmall?.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: space.stackTight),
                    Text(
                      'Earn 20% commission rebate on their bookings for 90 days',
                      style: context.text.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: space.stackItem),

          // Code display block
          Container(
            padding: space.insetCardCompact,
            decoration: BoxDecoration(
              color: colors.surfaceSubtle,
              borderRadius: shape.radiusControlSm,
              border: Border.all(
                color: colors.line,
                width: shape.borderDefault,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PERMANENT CODE',
                        style: context.text.labelSmall?.copyWith(
                          color: colors.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: space.stackTight),
                      Text(
                        displayCode,
                        style: context.text.titleMedium?.copyWith(
                          color: colors.textPrimary,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: hasCode ? () => _copyToClipboard(context) : null,
                  icon: Icon(
                    AppIcons.copy,
                    size: sizes.iconSm,
                    color: hasCode ? colors.brandPrimary : colors.textDisabled,
                  ),
                  tooltip: 'Copy Code',
                ),
              ],
            ),
          ),

          SizedBox(height: space.stackItem),

          // Action buttons: Copy Link & Share
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: hasCode ? () => _copyToClipboard(context) : null,
                  icon: Icon(AppIcons.copy, size: sizes.iconSm),
                  label: const Text('Copy Link'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textPrimary,
                    side: BorderSide(
                      color: colors.borderDefault,
                      width: shape.borderDefault,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: shape.radiusPill,
                    ),
                    padding: EdgeInsets.symmetric(vertical: space.stackItem),
                  ),
                ),
              ),
              SizedBox(width: space.inlineIconLabel),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: hasCode ? _shareLink : null,
                  icon: Icon(AppIcons.arrowUpRight, size: sizes.iconSm),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.brandPrimary,
                    foregroundColor: colors.textOnAction,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: shape.radiusPill,
                    ),
                    padding: EdgeInsets.symmetric(vertical: space.stackItem),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
