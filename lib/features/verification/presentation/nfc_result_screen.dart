import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trvlez_mobile/app/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_providers.dart';

/// Screen summarizing the successful read of the NFC passport chip.
/// Allows the user to confirm the extracted data before submitting the full verification to the backend.
class NfcResultScreen extends ConsumerWidget {
  const NfcResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final result = ref.watch(verificationNotifierProvider).nfcResult;

    if (result == null) {
      // Safety fallback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.nfcIntro);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final mrz = result.parsedMrz;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Chip Verified'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false, // Force them to use the action button
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success Header
              Center(
                child: result.faceImageBytes != null
                    ? Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 120,
                            height: 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.primary,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.shadow.withAlpha(20),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.memory(
                              result.faceImageBytes!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  child: Center(
                                    child: Icon(
                                      Icons.person_rounded,
                                      size: 56,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: context.colors.feedbackSuccess,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.check,
                                color: context.colors.textOnAction,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: context.colors.feedbackSuccess.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: context.colors.feedbackSuccess,
                          size: 48,
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              Text(
                'Passport Authenticated',
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your passport\'s digital signature is valid.',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withAlpha(180),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Data Card
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withAlpha(100),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withAlpha(80),
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (mrz != null) ...[
                          _buildDataRow(
                            context,
                            'Document No.',
                            mrz.documentNumber,
                          ),
                          const Divider(),
                          _buildDataRow(
                            context,
                            'Name',
                            '${mrz.firstName} ${mrz.lastName}',
                          ),
                          const Divider(),
                          _buildDataRow(
                            context,
                            'Nationality',
                            mrz.nationality,
                          ),
                          const Divider(),
                          _buildDataRow(
                            context,
                            'Date of Birth',
                            DateFormat.yMMMd().format(mrz.dateOfBirth),
                          ),
                          const Divider(),
                          _buildDataRow(
                            context,
                            'Expiry',
                            DateFormat.yMMMd().format(mrz.dateOfExpiry),
                          ),
                        ] else ...[
                          const Text('Data successfully read from chip.'),
                        ],

                        const SizedBox(height: 24),

                        // Technical info (security indicators)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withAlpha(
                              100,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSecurityRow(
                                context,
                                'Data Groups',
                                result.availableDataGroups
                                    .map((s) => s.toUpperCase())
                                    .join(', '),
                              ),
                              const SizedBox(height: 8),
                              _buildSecurityRow(
                                context,
                                'Active Auth',
                                result.activeAuthSignatureBase64 != null
                                    ? 'Verified'
                                    : 'Not Supported',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  // Final submission
                  ref
                      .read(verificationNotifierProvider.notifier)
                      .submitVerificationAsync();
                  context.go(AppRoutes.verificationStatus);
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Submit Verification'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withAlpha(150),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.cabin(
              fontSize: 16,
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}
