import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'verification_notifier.dart';
import 'widgets/verification_progress_bar.dart';

/// Screen for reviewing MRZ-extracted passport details before confirmation.
///
/// Displays extracted fields in a read-only card layout. The traveller can
/// confirm the data (persists to profile) or re-upload their passport.
class MrzReviewScreen extends StatelessWidget {
  final VerificationNotifier notifier;

  const MrzReviewScreen({super.key, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notifier,
      builder: (context, _) {
        final mrz = notifier.mrzExtractionResult;
        final phase = notifier.phase;
        final error = notifier.errorMessage;
        final isConfirming = phase == VerificationPhase.confirmingMrz;

        if (mrz == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Review Passport')),
            body: const Center(child: Text('No passport data available')),
          );
        }

        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Review Details'),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Progress bar — Step 2 (Review)
                VerificationProgressBar.verification(currentStepIndex: 1),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Confirm Your Details',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We extracted the following details from your passport. '
                          'Please verify they are correct.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withAlpha(150),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Passport details card
                        Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.dividerColor.withAlpha(30),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withAlpha(8),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Header
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withAlpha(10),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.badge_outlined,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Passport Information',
                                      style: GoogleFonts.nunito(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Fields
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
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
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.error.withAlpha(15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.error.withAlpha(50),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: colorScheme.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    error,
                                    style: TextStyle(
                                      color: colorScheme.error,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),

                        // Continue button
                        FilledButton(
                          onPressed: isConfirming
                              ? null
                              : () async {
                                  await notifier.confirmMrz();
                                  if (context.mounted &&
                                      notifier.phase ==
                                          VerificationPhase.mrzReviewed) {
                                    context.push(
                                      '/verification/selfie-instructions',
                                    );
                                  }
                                },
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isConfirming
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Confirm & Continue'),
                        ),
                        const SizedBox(height: 12),

                        // Re-upload button
                        OutlinedButton(
                          onPressed: isConfirming
                              ? null
                              : () {
                                  notifier.clearImage();
                                  context.pop();
                                },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Re-upload Passport'),
                        ),
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
                style: GoogleFonts.cabin(
                  fontSize: 14,
                  color: colorScheme.onSurface.withAlpha(150),
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
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
            color: theme.dividerColor.withAlpha(20),
          ),
      ],
    );
  }
}
