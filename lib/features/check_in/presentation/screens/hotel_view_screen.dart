import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
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
    final stateAsync = ref.watch(checkInNotifierProvider(reservationId));

    return stateAsync.when(
      loading: () => Scaffold(
        backgroundColor: colors.page,
        body: const Center(child: LoadingView()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: colors.page,
        body: Center(
          child: ErrorView(
            message: err.toString(),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm + 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border(bottom: BorderSide(color: colors.line)),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => context.pop(),
                        child: Icon(
                          AppIcons.arrowLeft,
                          size: 18,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'What the hotel gets',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 16,
                          fontWeight: TypeScale.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'When ${details.hotel} scans your code, this is everything that appears on their screen.',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13,
                            color: colors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

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
                        const SizedBox(height: AppSpacing.lg),

                        // Not Shared Section
                        _NotSharedSection(),
                        const SizedBox(height: AppSpacing.lg),

                        // Registration Form Preview (if paper card required)
                        if (hasForm) ...[
                          _RegistrationFormSection(hotelName: details.hotel),
                          const SizedBox(height: AppSpacing.lg),
                        ],

                        Text(
                          "Some countries require hotels to record passport details. If yours does, we'll ask you first.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11,
                            color: colors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
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

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.hotelScreen,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: SvgPicture.asset(
                  'assets/art/guest_photo.svg',
                  width: 48,
                  height: 58,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guestName,
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 15,
                        fontWeight: TypeScale.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      bookingRef,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        color: colors.hotelMeta,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.hotelOkFill,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.check,
                            size: 10,
                            color: colors.hotelOkInk,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ID VERIFIED',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 10,
                              fontWeight: TypeScale.bold,
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
          const SizedBox(height: AppSpacing.md),
          Divider(color: colors.hotelLine, height: 1),
          const SizedBox(height: AppSpacing.sm + 2),
          _TerminalRow(label: 'Stay', value: dates),
          const SizedBox(height: AppSpacing.xs),
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

    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              color: colors.hotelLabel,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              fontWeight: TypeScale.medium,
              color: Colors.white,
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
    const notSharedItems = [
      'Passport scans or documents',
      'Selfie video or biometric data',
      'Credit card or payment numbers',
      'Past trips or other bookings',
      'Address or contact details',
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Not shared with the hotel',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              fontWeight: TypeScale.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final item in notSharedItems) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.5),
              child: Row(
                children: [
                  Icon(AppIcons.eyeOff, size: 14, color: colors.textSecondary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
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

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.alertTriangle,
                size: 16,
                color: colors.feedbackWarning,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Paper Registration Form',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 13,
                    fontWeight: TypeScale.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'If $hotelName asks you to complete a paper card at reception, only share the required identity fields.',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              color: colors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
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
