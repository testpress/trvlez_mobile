import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String timeAgo;
  final IconData icon;
  final bool isUnread;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.icon,
    this.isUnread = false,
  });
}

/// Notification dropdown sheet displaying recent traveler alerts.
class NotificationsSheet extends StatefulWidget {
  const NotificationsSheet({
    super.key,
    required this.items,
    required this.onClearAll,
  });

  final List<NotificationItem> items;
  final VoidCallback onClearAll;

  static Future<void> show(
    BuildContext context, {
    required List<NotificationItem> items,
    required VoidCallback onClearAll,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          NotificationsSheet(items: items, onClearAll: onClearAll),
    );
  }

  @override
  State<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<NotificationsSheet> {
  late List<NotificationItem> _currentItems;

  @override
  void initState() {
    super.initState();
    _currentItems = List.from(widget.items);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final unreadCount = _currentItems.where((i) => i.isUnread).length;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        MediaQuery.viewPaddingOf(context).bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: colors.cardBorderSoft,
                borderRadius: AppRadius.fullRadius,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Text(
                'Notifications',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 16,
                  fontWeight: TypeScale.bold,
                  color: colors.textPrimary,
                ),
              ),
              if (unreadCount > 0) ...[
                const SizedBox(width: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.brandPrimary,
                    borderRadius: AppRadius.fullRadius,
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 10,
                      fontWeight: TypeScale.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (_currentItems.isNotEmpty)
                TextButton(
                  onPressed: () {
                    widget.onClearAll();
                    setState(() {
                      _currentItems = _currentItems
                          .map(
                            (i) => NotificationItem(
                              id: i.id,
                              title: i.title,
                              body: i.body,
                              timeAgo: i.timeAgo,
                              icon: i.icon,
                              isUnread: false,
                            ),
                          )
                          .toList();
                    });
                  },
                  child: Text(
                    'Mark all read',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 12,
                      fontWeight: TypeScale.semiBold,
                      color: colors.brandPrimary,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          if (_currentItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: Text(
                  'No notifications right now',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _currentItems.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: colors.cardBorderSoft),
                itemBuilder: (context, index) {
                  final item = _currentItems[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                      horizontal: AppSpacing.xs,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colors.redTint,
                            borderRadius: AppRadius.mdRadius,
                          ),
                          child: Icon(
                            item.icon,
                            size: 16,
                            color: colors.brandPrimary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 13,
                                  fontWeight: item.isUnread
                                      ? TypeScale.bold
                                      : TypeScale.semiBold,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.body,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 12,
                                  color: colors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.timeAgo,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 10,
                                  color: colors.inkTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (item.isUnread)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(
                              color: colors.brandPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
