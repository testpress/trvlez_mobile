import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';
import 'package:trvlez_mobile/core/widgets/loading_view.dart';
import 'package:trvlez_mobile/features/profile/domain/traveler_verification_state.dart';
import 'package:trvlez_mobile/features/reservations/presentation/providers/reservations_providers.dart';
import 'package:trvlez_mobile/features/reservations/presentation/widgets/booking_action_footer.dart';
import 'package:trvlez_mobile/features/reservations/presentation/widgets/booking_instructions_card.dart';
import 'package:trvlez_mobile/features/reservations/presentation/widgets/booking_summary_card.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_providers.dart';

/// Screen displayed immediately after a successful reservation creation.
class BookingConfirmationScreen extends StatelessWidget {
  final String reservationId;
  final Reservation? reservation;
  final ReservationRepository? repository;
  final bool? isKycVerified;
  final TravelerVerificationState? verificationState;

  BookingConfirmationScreen({
    super.key,
    String? reservationId,
    this.reservation,
    this.repository,
    this.isKycVerified,
    this.verificationState,
  }) : reservationId = reservationId ?? reservation?.id ?? '';

  @override
  Widget build(BuildContext context) {
    if (repository != null) {
      return ProviderScope(
        overrides: [
          reservationRepositoryProvider.overrideWithValue(repository!),
        ],
        child: _BookingConfirmationContent(
          reservationId: reservationId,
          reservation: reservation,
          isKycVerified: isKycVerified,
          verificationState: verificationState,
        ),
      );
    }

    return _BookingConfirmationContent(
      reservationId: reservationId,
      reservation: reservation,
      isKycVerified: isKycVerified,
      verificationState: verificationState,
    );
  }
}

class _BookingConfirmationContent extends ConsumerWidget {
  final String reservationId;
  final Reservation? reservation;
  final bool? isKycVerified;
  final TravelerVerificationState? verificationState;

  const _BookingConfirmationContent({
    required this.reservationId,
    this.reservation,
    this.isKycVerified,
    this.verificationState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    if (reservation != null) {
      return _buildScaffold(context, ref, reservation!);
    }

    final detailAsync = ref.watch(
      reservationDetailNotifierProvider(reservationId),
    );

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(
          'Confirmation',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go(AppRoutes.home),
        ),
        elevation: 0,
      ),
      body: detailAsync.when(
        data: (loadedReservation) => _buildBody(context, ref, loadedReservation),
        loading:
            () => const LoadingView(
              message: 'Loading your booking confirmation...',
            ),
        error:
            (err, stack) => ErrorView(
              title: 'Unable to load confirmation',
              message: err.toString(),
              onRetry: () {
                ref
                    .read(reservationDetailNotifierProvider(reservationId).notifier)
                    .refresh();
              },
            ),
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    WidgetRef ref,
    Reservation displayReservation,
  ) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(
          'Confirmation',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go(AppRoutes.home),
        ),
        elevation: 0,
      ),
      body: _buildBody(context, ref, displayReservation),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    Reservation displayReservation,
  ) {
    final colors = context.colors;
    final TravelerVerificationState currentVerification =
        verificationState ?? ref.watch(travelerVerificationStateProvider);
    final verified = isKycVerified ?? currentVerification.isVerified;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Success Header Icon
            Center(
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: colors.actionPrimary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 48,
                  color: colors.actionPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: Text(
                'Booking Confirmed!',
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Summary Card
            BookingSummaryCard(reservation: displayReservation),
            const SizedBox(height: AppSpacing.md),

            // Instructions / KYC Warning
            if (!verified) ...[
              BookingInstructionsCard(
                verificationState: currentVerification,
                propertyName: displayReservation.propertySummary.name,
                onVerifyTap: () {
                  if (currentVerification.needsOnboarding) {
                    context.push(AppRoutes.onboarding);
                  } else {
                    context.push(AppRoutes.verificationStatus);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Action Footer
            BookingActionFooter(
              reservation: displayReservation,
              isKycVerified: verified,
              verificationState: currentVerification,
              onStartVerification: () {
                if (currentVerification.needsOnboarding) {
                  context.push(AppRoutes.onboarding);
                } else {
                  context.push(AppRoutes.verificationStatus);
                }
              },
              onViewTrips: () => context.go(AppRoutes.myTrips),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
