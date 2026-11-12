import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/app_pinned_header.dart';
import 'package:trvlez_mobile/core/widgets/ez_word.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_app_button.dart';

/// Screen view when a user navigates directly to booking without an active property draft.
class BookingNoSelectionView extends StatelessWidget {
  const BookingNoSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;

    return Scaffold(
      backgroundColor: colors.page,
      body: Column(
        children: [
          AppPinnedHeader(
            child: Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.pop(),
                  child: Padding(
                    padding: EdgeInsets.all(space.stackText),
                    child: Icon(
                      AppIcons.arrowLeft,
                      size: sizes.iconMd,
                      color: colors.ink,
                    ),
                  ),
                ),
                SizedBox(width: space.inlineIconLabel),
                EzWord(
                  rest: 'Stays',
                  style: context.text.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.ink,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: space.insetDialog,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Open a property from ezStays or Saved to start a booking.',
                      textAlign: TextAlign.center,
                      style: context.text.labelLarge?.copyWith(
                        color: colors.inkSecondary,
                      ),
                    ),
                    SizedBox(height: space.stackSection),
                    BookingAppButton(
                      label: 'Go to ezStays',
                      onPressed: () => context.go(AppRoutes.ezStays),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
