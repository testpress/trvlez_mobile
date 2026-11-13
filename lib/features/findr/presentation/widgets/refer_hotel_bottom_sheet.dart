import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/features/findr/presentation/widgets/refer_hotel_form.dart';

/// Shows the "Refer a Hotel" modal bottom sheet.
Future<bool?> showReferHotelSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.colors.transparent,
    builder: (modalContext) => const ReferHotelBottomSheet(),
  );
}

/// Clean bottom sheet form to submit a prospective hotel partner invitation.
///
/// Composes canonical [ReferHotelForm].
class ReferHotelBottomSheet extends StatelessWidget {
  const ReferHotelBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: sizes.containerForm),
        child: Container(
          padding: EdgeInsets.only(bottom: bottomInset),
          decoration: BoxDecoration(
            color: colors.page,
            borderRadius: shape.radiusOverlay,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: space.stackTight),
                    width: sizes.controlSm,
                    height: space.stackText,
                    decoration: BoxDecoration(
                      color: colors.line,
                      borderRadius: shape.radiusPill,
                    ),
                  ),
                ),
                Padding(
                  padding: space.insetCard,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Refer a Hotel',
                              style: context.text.titleLarge?.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: space.stackTight),
                            Text(
                              'Your claim is locked at the moment you submit',
                              style: context.text.bodySmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          AppIcons.close,
                          size: sizes.iconMd,
                          color: colors.textSecondary,
                        ),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                const Expanded(child: ReferHotelForm()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
