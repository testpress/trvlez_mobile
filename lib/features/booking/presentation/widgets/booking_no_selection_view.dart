import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_pinned_header.dart';
import 'package:trvlez_mobile/core/widgets/ez_word.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_app_button.dart';

/// Screen view when a user navigates directly to booking without an active property draft.
class BookingNoSelectionView extends StatelessWidget {
  const BookingNoSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: Icon(
                      AppIcons.arrowLeft,
                      size: 20.0,
                      color: colors.ink,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                EzWord(
                  rest: 'Stays',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 16.0,
                    fontWeight: TypeScale.bold,
                    color: colors.ink,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Open a property from ezStays or Saved to start a booking.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14.0,
                        color: colors.inkSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
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
