import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trvlez_mobile/app/routes.dart';
import 'package:trvlez_mobile/features/verification/domain/verification_event.dart';
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
        automaticallyImplyLeading: false,
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
                    ? Container(
                        width: 120,
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 4,
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
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.verified_user_rounded,
                          size: 64,
                          color: theme.colorScheme.primary,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                'ePassport Read Successfully',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Data from the secure chip has been matched with your profile.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withAlpha(180),
                ),
              ),
              const SizedBox(height: 24),

              // Chip Data Summary
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withAlpha(
                      50,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
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
                        _buildDataRow(context, 'Nationality', mrz.nationality),
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
                          children: [
                            _buildSecurityRow(
                              context,
                              'Passive Authentication (SOD)',
                              result.isPassiveAuthSuccess
                                  ? 'PASSED'
                                  : 'SKIPPED',
                            ),
                            const SizedBox(height: 4),
                            _buildSecurityRow(
                              context,
                              'Chip Access (BAC/PACE)',
                              result.isChipAccessSuccess ? 'SUCCESS' : 'FAILED',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Action button
              FilledButton(
                onPressed: () {
                  ref
                      .read(verificationNotifierProvider.notifier)
                      .send(SubmitRequested(nfcPayload: result.toJson()));
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
