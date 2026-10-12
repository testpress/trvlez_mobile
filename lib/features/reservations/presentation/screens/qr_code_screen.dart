import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';
import 'package:trvlez_mobile/core/widgets/loading_view.dart';
import 'package:trvlez_mobile/features/reservations/presentation/providers/reservations_providers.dart';
import 'package:trvlez_mobile/features/reservations/presentation/widgets/qr_code_card.dart';
import 'package:trvlez_mobile/features/reservations/presentation/widgets/reservation_overview_tile.dart';

/// Screen displaying the traveler's dynamic QR check-in token pass.
class QrCodeScreen extends StatelessWidget {
  final String reservationId;
  final Reservation? reservation;
  final ReservationRepository? repository;
  final bool? isKycVerified;
  final TravelerVerificationState? verificationState;

  QrCodeScreen({
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
        child: _QrCodeScreenContent(
          reservationId: reservationId,
          reservation: reservation,
          isKycVerified: isKycVerified,
          verificationState: verificationState,
        ),
      );
    }

    return _QrCodeScreenContent(
      reservationId: reservationId,
      reservation: reservation,
      isKycVerified: isKycVerified,
      verificationState: verificationState,
    );
  }
}

class _QrCodeScreenContent extends ConsumerStatefulWidget {
  final String reservationId;
  final Reservation? reservation;
  final bool? isKycVerified;
  final TravelerVerificationState? verificationState;

  const _QrCodeScreenContent({
    required this.reservationId,
    this.reservation,
    this.isKycVerified,
    this.verificationState,
  });

  @override
  ConsumerState<_QrCodeScreenContent> createState() =>
      _QrCodeScreenContentState();
}

class _QrCodeScreenContentState extends ConsumerState<_QrCodeScreenContent> {
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoGenerateTokenIfNeeded();
    });
  }

  void _autoGenerateTokenIfNeeded() {
    final TravelerVerificationState verification =
        widget.verificationState ?? ref.read(travelerVerificationStateProvider);
    final isVerified = widget.isKycVerified ?? verification.isVerified;
    if (!isVerified) return;

    final tokenState = ref.read(checkInTokenProvider(widget.reservationId));
    final token = tokenState.value;
    if (token == null || DateTime.now().isAfter(token.expiresAt)) {
      _generateToken();
    }
  }

  void _generateToken() {
    final TravelerVerificationState verification =
        widget.verificationState ?? ref.read(travelerVerificationStateProvider);
    final isVerified = widget.isKycVerified ?? verification.isVerified;
    if (!isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Identity verification (KYC) is required to generate a check-in pass.',
          ),
          action: SnackBarAction(
            label: 'Verify Now',
            onPressed: () {
              if (verification.needsOnboarding) {
                context.push(AppRoutes.onboarding);
              } else {
                context.push(AppRoutes.verificationStatus);
              }
            },
          ),
        ),
      );
      return;
    }

    ref
        .read(checkInTokenProvider(widget.reservationId).notifier)
        .generateCheckInToken();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tokenState = ref.watch(checkInTokenProvider(widget.reservationId));

    if (widget.reservation != null) {
      return _buildScaffold(context, widget.reservation!, tokenState);
    }

    final detailAsync = ref.watch(
      reservationDetailNotifierProvider(widget.reservationId),
    );

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Check-in QR Code',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: detailAsync.when(
        data: (reservation) => _buildBody(context, reservation, tokenState),
        loading: () =>
            const LoadingView(message: 'Loading reservation details...'),
        error: (err, stack) => ErrorView(
          title: 'Unable to load reservation',
          message: err.toString(),
          onRetry: () {
            ref
                .read(
                  reservationDetailNotifierProvider(
                    widget.reservationId,
                  ).notifier,
                )
                .refresh();
          },
        ),
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    Reservation reservation,
    AsyncValue<CheckInToken?> tokenState,
  ) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Check-in QR Code',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: _buildBody(context, reservation, tokenState),
    );
  }

  Widget _buildBody(
    BuildContext context,
    Reservation reservation,
    AsyncValue<CheckInToken?> tokenState,
  ) {
    final TravelerVerificationState verificationState =
        widget.verificationState ??
        ref.watch(travelerVerificationStateProvider);
    final isVerified = widget.isKycVerified ?? verificationState.isVerified;

    final token = tokenState.value;
    final isLoading = tokenState.isLoading;
    final isExpired = token != null && DateTime.now().isAfter(token.expiresAt);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.md,
        ),
        child: Column(
          children: [
            ReservationOverviewTile(reservation: reservation),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: isVerified
                  ? _buildQrSection(tokenState, token, isExpired)
                  : _KycRequiredView(
                      verificationState: verificationState,
                      onActionPressed: () =>
                          _handleKycAction(context, verificationState),
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (isVerified)
              AppButton(
                label: token == null
                    ? 'Generate QR Code'
                    : isExpired
                    ? 'Refresh QR Code'
                    : 'Regenerate Pass',
                isLoading: isLoading,
                onPressed: _generateToken,
              )
            else
              AppButton(
                label: verificationState.needsOnboarding
                    ? 'Start Identity Verification'
                    : 'Check Verification Status',
                onPressed: () => _handleKycAction(context, verificationState),
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  void _handleKycAction(
    BuildContext context,
    TravelerVerificationState verificationState,
  ) {
    if (verificationState.needsOnboarding) {
      context.push(AppRoutes.onboarding);
    } else {
      context.push(AppRoutes.verificationStatus);
    }
  }

  Widget _buildQrSection(
    AsyncValue<CheckInToken?> tokenState,
    CheckInToken? token,
    bool isExpired,
  ) {
    if (tokenState.isLoading && !tokenState.hasValue) {
      return const LoadingView(message: 'Generating secure QR token...');
    }

    if (tokenState.hasError && token == null) {
      return ErrorView(
        title: 'Token Generation Failed',
        message: tokenState.error.toString(),
        onRetry: _generateToken,
      );
    }

    if (token == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_2_rounded,
              size: 80,
              color: context.colors.textDisabled,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Active Check-in Pass',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Tap below to generate your check-in QR code pass.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return QrCodeCard(token: token, isExpired: isExpired);
  }
}

class _KycRequiredView extends StatelessWidget {
  final TravelerVerificationState verificationState;
  final VoidCallback onActionPressed;

  const _KycRequiredView({
    required this.verificationState,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.feedbackWarning.withAlpha(20),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.feedbackWarning.withAlpha(80)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 48,
              color: colors.feedbackWarning,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Verification Required',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'To receive your digital room key and check-in pass, your identity must be verified before arrival.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
