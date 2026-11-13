import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';
import 'package:trvlez_mobile/core/widgets/loading_view.dart';
import 'package:trvlez_mobile/features/check_in/presentation/providers/check_in_providers.dart';
import 'package:trvlez_mobile/features/check_in/presentation/widgets/hotel_screen_terminal_card.dart';
import 'package:trvlez_mobile/features/check_in/presentation/widgets/hotel_view_privacy_card.dart';
import 'package:trvlez_mobile/features/check_in/presentation/widgets/hotel_view_registration_form_card.dart';

/// Screen 5.8: The hotel-side view showing the minimal data the reception sees upon scanning the pass.
class HotelViewScreen extends ConsumerWidget {
  const HotelViewScreen({
    super.key,
    required this.reservationId,
    this.hasForm = true,
  });

  final String reservationId;
  final bool hasForm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final stateAsync = ref.watch(checkInNotifierProvider(reservationId));

    return stateAsync.when(
      loading: () => Scaffold(
        backgroundColor: colors.page,
        body: const Center(child: LoadingView()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: colors.page,
        body: Center(
          child: ErrorView.fromError(
            error: err,
            onRetry: () =>
                ref.invalidate(checkInNotifierProvider(reservationId)),
          ),
        ),
      ),
      data: (details) {
        final guestName = details.reservation.guestName.isNotEmpty
            ? details.reservation.guestName
            : 'Amara Okafor';

        final roomType = details.reservation.rooms.isNotEmpty
            ? (details.reservation.rooms.first.roomTypeName ?? 'Standard Room')
            : 'Standard Room';

        return Scaffold(
          backgroundColor: colors.page,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // App Bar
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: space.insetCard.left,
                    vertical: space.stackItem,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: colors.line,
                        width: shape.borderDefault,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => context.pop(),
                        child: Icon(
                          AppIcons.arrowLeft,
                          size: sizes.iconSm,
                          color: colors.textPrimary,
                        ),
                      ),
                      SizedBox(width: space.inlineItem),
                      Text(
                        'What the hotel gets',
                        style: context.text.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: space.insetCard,
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'When ${details.hotel} scans your code, this is everything that appears on their screen.',
                          style: context.text.titleSmall?.copyWith(
                            color: colors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: space.stackFormField),

                        // Dark Terminal Panel
                        HotelScreenTerminalCard(
                          guestName: guestName,
                          bookingRef: details.reservation.confirmationCode,
                          dates: details.datesFormatted,
                          roomType: roomType,
                        ),
                        SizedBox(height: space.stackSection),

                        // Not Shared Section
                        const HotelViewPrivacyCard(),
                        SizedBox(height: space.stackSection),

                        // Registration Form Preview (if paper card required)
                        if (hasForm) ...[
                          HotelViewRegistrationFormCard(
                            hotelName: details.hotel,
                          ),
                          SizedBox(height: space.stackSection),
                        ],

                        Text(
                          "Some countries require hotels to record passport details. If yours does, we'll ask you first.",
                          textAlign: TextAlign.center,
                          style: context.text.bodySmall?.copyWith(
                            color: colors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                        SizedBox(height: space.stackHero),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
