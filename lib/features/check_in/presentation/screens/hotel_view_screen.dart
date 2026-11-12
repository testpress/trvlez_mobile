import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';
import 'package:trvlez_mobile/core/widgets/loading_view.dart';
import 'package:trvlez_mobile/features/check_in/presentation/providers/check_in_providers.dart';

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
                        _DarkHotelScreen(
                          guestName: guestName,
                          bookingRef: details.reservation.confirmationCode,
                          dates: details.datesFormatted,
                          roomType: details.reservation.rooms.isNotEmpty
                              ? (details.reservation.rooms.first.roomTypeName ??
                                    'Standard Room')
                              : 'Standard Room',
                        ),
                        SizedBox(height: space.stackSection),

                        // Not Shared Section
                        _NotSharedSection(),
                        SizedBox(height: space.stackSection),

                        // Registration Form Preview (if paper card required)
                        if (hasForm) ...[
                          _RegistrationFormSection(hotelName: details.hotel),
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

class _DarkHotelScreen extends StatelessWidget {
  const _DarkHotelScreen({
    required this.guestName,
    required this.bookingRef,
    required this.dates,
    required this.roomType,
  });

  final String guestName;
  final String bookingRef;
  final String dates;
  final String roomType;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Container(
      padding: space.insetCard,
      decoration: BoxDecoration(
        color: colors.hotelScreen,
        borderRadius: shape.radiusSurface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: shape.radiusControlSm,
                child: SvgPicture.asset(
                  'assets/art/guest_photo.svg',
                  width: 48,
                  height: 58,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: space.inlineItem),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guestName,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.brandOnSurface,
                      ),
                    ),
                    SizedBox(height: space.stackText),
                    Text(
                      bookingRef,
                      style: context.text.labelMedium?.copyWith(
                        color: colors.hotelMeta,
                      ),
                    ),
                    SizedBox(height: space.stackTight),
                    Container(
                      padding: space.insetTag,
                      decoration: BoxDecoration(
                        color: colors.hotelOkFill,
                        borderRadius: shape.radiusPill,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.check,
                            size: sizes.iconXs,
                            color: colors.hotelOkInk,
                          ),
                          SizedBox(width: space.inlineMicro),
                          Text(
                            'ID VERIFIED',
                            style: context.text.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.hotelOkInk,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: space.stackFormField),
          Divider(color: colors.hotelLine, height: shape.dividerDefault),
          SizedBox(height: space.stackItem),
          _TerminalRow(label: 'Stay', value: dates),
          SizedBox(height: space.stackText),
          _TerminalRow(label: 'Room', value: roomType),
        ],
      ),
    );
  }
}

class _TerminalRow extends StatelessWidget {
  const _TerminalRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final sizes = context.sizes;

    return Row(
      children: [
        SizedBox(
          width: sizes.controlXl + space.inlineMicro,
          child: Text(
            label,
            style: context.text.labelMedium?.copyWith(color: colors.hotelLabel),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: context.text.labelMedium?.copyWith(
              color: colors.brandOnSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _NotSharedSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    const notSharedItems = [
      'Passport scans or documents',
      'Selfie video or biometric data',
      'Credit card or payment numbers',
      'Past trips or other bookings',
      'Address or contact details',
    ];

    return Container(
      padding: space.insetCard,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: shape.radiusControl,
        border: Border.all(color: colors.line, width: shape.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Not shared with the hotel',
            style: context.text.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: space.stackItem),
          for (final item in notSharedItems) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: space.stackText),
              child: Row(
                children: [
                  Icon(
                    AppIcons.eyeOff,
                    size: sizes.iconXs,
                    color: colors.textSecondary,
                  ),
                  SizedBox(width: space.inlineIconLabel),
                  Expanded(
                    child: Text(
                      item,
                      style: context.text.labelMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RegistrationFormSection extends StatelessWidget {
  const _RegistrationFormSection({required this.hotelName});

  final String hotelName;

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
        borderRadius: shape.radiusControl,
        border: Border.all(color: colors.line, width: shape.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.alertTriangle,
                size: sizes.iconSm,
                color: colors.feedbackWarning,
              ),
              SizedBox(width: space.inlineIconLabel),
              Expanded(
                child: Text(
                  'Paper Registration Form',
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: space.stackText),
          Text(
            'If $hotelName asks you to complete a paper card at reception, only share the required identity fields.',
            style: context.text.labelMedium?.copyWith(
              color: colors.textSecondary,
              height: 1.35,
            ),
          ),
          SizedBox(height: space.stackFormField),
          Center(
            child: SvgPicture.asset(
              'assets/art/registration_form.svg',
              width: 140,
              height: 100,
            ),
          ),
        ],
      ),
    );
  }
}
