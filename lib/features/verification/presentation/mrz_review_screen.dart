import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:trvlez_mobile/features/verification/presentation/verification_notifier.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/kyc_progress_stepper.dart';

/// Screen for reviewing MRZ-extracted passport details before confirmation.
///
/// Displays extracted fields in a read-only card layout. The traveller can
/// confirm the data (persists to profile) or re-upload their passport.
class MrzReviewScreen extends StatelessWidget {
  final VerificationNotifier notifier;

  const MrzReviewScreen({super.key, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListenableBuilder(
      listenable: notifier,
      builder: (context, _) {
        final mrz = notifier.mrzExtractionResult;
        final phase = notifier.phase;
        final error = notifier.errorMessage;
        final isConfirming = phase == VerificationPhase.confirmingMrz;

        if (mrz == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'KYC',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: colorScheme.onSurface,
                ),
              ),
              centerTitle: true,
            ),
            body: const Center(child: Text('No passport data available')),
          );
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'KYC',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: colorScheme.onSurface,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface, size: 18),
              onPressed: () {
                notifier.clearImage();
                context.go('/verification/passport-capture');
              },
            ),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await notifier.fetchVerificationStatus();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Horizontal Stepper Progress Indicator - Step 2 (Review) is active
                    const KycProgressStepper(progressIndex: 1),
                    const SizedBox(height: 24),

                    // Central Card Container
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Confirm Your Details',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We extracted the following details from your passport. Please verify they are correct.',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface.withValues(alpha: 0.65),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Passport information fields
                          _DetailRow(
                            label: 'First Name',
                            value: mrz.firstName ?? '—',
                          ),
                          _DetailRow(
                            label: 'Last Name',
                            value: mrz.lastName ?? '—',
                          ),
                          _DetailRow(
                            label: 'Passport Number',
                            value: mrz.documentNumber ?? '—',
                          ),
                          _DetailRow(
                            label: 'Nationality',
                            value: mrz.nationality ?? '—',
                          ),
                          _DetailRow(
                            label: 'Date of Birth',
                            value: mrz.dateOfBirth ?? '—',
                          ),
                          _DetailRow(
                            label: 'Passport Expiry',
                            value: mrz.dateOfExpiry ?? '—',
                          ),
                          _DetailRow(
                            label: 'Gender',
                            value: _formatSex(mrz.sex),
                            showDivider: false,
                          ),
                          const SizedBox(height: 20),

                          if (error != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.error.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: colorScheme.error.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    color: colorScheme.error,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      error,
                                      style: GoogleFonts.inter(
                                        color: colorScheme.error,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Continue button
                          ElevatedButton(
                            onPressed: isConfirming
                                ? null
                                : () async {
                                    await notifier.confirmMrz();
                                    if (context.mounted &&
                                        notifier.phase == VerificationPhase.mrzReviewed) {
                                      context.push('/verification/selfie-instructions');
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.onSurface,
                              foregroundColor: colorScheme.surface,
                              minimumSize: const Size(double.infinity, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              elevation: 0,
                            ),
                            child: isConfirming
                                ? SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colorScheme.surface,
                                    ),
                                  )
                                : Text(
                                    'Confirm & Continue',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 12),

                          // Re-upload button
                          OutlinedButton(
                            onPressed: isConfirming
                                ? null
                                : () {
                                    notifier.clearImage();
                                    context.go('/verification/passport-capture');
                                  },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              side: BorderSide(color: colorScheme.primary),
                              minimumSize: const Size(double.infinity, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: Text(
                              'Re-upload Passport',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Footer text
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: colorScheme.onSurface.withValues(alpha: 0.65),
                            ),
                            children: [
                              const TextSpan(
                                text: 'If you are facing any difficulties, please get in touch with us on ',
                              ),
                              TextSpan(
                                text: 'Whatsapp',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF25D366),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  String _formatSex(String? sex) {
    if (sex == null || sex.isEmpty) return '—';
    switch (sex.toUpperCase()) {
      case 'M':
        return 'Male';
      case 'F':
        return 'Female';
      default:
        return sex;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;

  const _DetailRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
      ],
    );
  }
}
