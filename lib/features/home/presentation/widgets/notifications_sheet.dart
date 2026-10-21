import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
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
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final unreadCount = _currentItems.where((i) => i.isUnread).length;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: shape.radiusOverlay.topLeft),
      ),
      padding: EdgeInsets.fromLTRB(
        space.stackSection,
        space.stackItem,
        space.stackSection,
        MediaQuery.viewPaddingOf(context).bottom + space.inlineItem,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: sizes.controlSm,
              height: sizes.indicatorProgressHeight,
              margin: EdgeInsets.symmetric(vertical: space.stackItem),
              decoration: BoxDecoration(
                color: colors.cardBorderSoft,
                borderRadius: shape.radiusPill,
              ),
            ),
          ),
          SizedBox(height: space.stackText),
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
                SizedBox(width: space.inlineMicro),
                Container(
                  padding: space.insetTagSm,
                  decoration: BoxDecoration(
                    color: colors.brandPrimary,
                    borderRadius: shape.radiusPill,
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
          Divider(height: space.stackSection),
          if (_currentItems.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: space.stackHero),
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
                separatorBuilder: (context, index) => Divider(
                  height: shape.borderDefault,
                  color: colors.cardBorderSoft,
                ),
                itemBuilder: (context, index) {
                  final item = _currentItems[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: space.stackFormField,
                      horizontal: space.inlineMicro,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: sizes.iconXl,
                          height: sizes.iconXl,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colors.redTint,
                            borderRadius: shape.radiusControl,
                          ),
                          child: Icon(
                            item.icon,
                            size: sizes.iconSm,
                            color: colors.brandPrimary,
                          ),
                        ),
                        SizedBox(width: space.inlineItem),
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
                              SizedBox(height: space.stackText),
                              Text(
                                item.body,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: 12,
                                  color: colors.textSecondary,
                                ),
                              ),
                              SizedBox(height: space.stackText),
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
                            width: space.stackTight,
                            height: space.stackTight,
                            margin: EdgeInsets.only(top: space.stackTight),
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
