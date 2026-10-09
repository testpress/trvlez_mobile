import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/kyc_progress_stepper.dart';

/// Screen that introduces the NFC passport reading feature to the user.
/// Explains the benefits and requirements, offering options to proceed or skip.
class NfcIntroScreen extends ConsumerWidget {
  const NfcIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Horizontal Stepper Progress Indicator - Step 4 (NFC) is active
              const KycProgressStepper(progressIndex: 3),
              const SizedBox(height: 24),

              // Central Card Container
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
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
                    // Illustration / Icon
                    Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: 44,
                              color: colorScheme.primary.withValues(alpha: 0.7),
                            ),
                            Positioned(
                              right: 20,
                              bottom: 20,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.nfc_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Text Content
                    Text(
                      'Verify with NFC',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'For the highest security and fastest processing, we recommend reading your passport\'s secure NFC chip.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.65),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Requirements List
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: colorScheme.outlineVariant,
                          width: 0.8,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'You will need:',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildRequirementRow(
                            Icons.app_settings_alt_rounded,
                            'A phone with NFC enabled',
                            colorScheme,
                          ),
                          const SizedBox(height: 8),
                          _buildRequirementRow(
                            Icons.nfc_rounded,
                            'An ePassport with the biometric symbol',
                            colorScheme,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action Buttons
                    ElevatedButton(
                      onPressed: () {
                        context.push(AppRoutes.nfcScan);
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
                      child: Text(
                        'Start NFC Scan',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => _showSkipDialog(context, ref),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                        minimumSize: const Size(double.infinity, 44),
                      ),
                      child: Text(
                        'Skip for now',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
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
                          text:
                              'If you are facing any difficulties, please get in touch with us on ',
                        ),
                        TextSpan(
                          text: 'Whatsapp',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: context.colors.feedbackSuccess,
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
    );
  }

  Widget _buildRequirementRow(
    IconData icon,
    String text,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showSkipDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip NFC Scan?'),
        content: const Text(
          'NFC verification provides the highest level of trust and may speed up your application processing. Are you sure you want to skip?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Skip'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Show loading overlay
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      ref.read(verificationNotifierProvider.notifier).skipNfc();
      await ref
          .read(verificationNotifierProvider.notifier)
          .submitVerificationAsync();

      if (context.mounted) {
        // Pop loading overlay
        Navigator.pop(context);

        final state = ref.read(verificationNotifierProvider);
        if (state.phase == VerificationPhase.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Submission failed'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else {
          // Skipping NFC marks the flow as complete (for MVP).
          context.go(AppRoutes.verificationStatus);
        }
      }
    }
  }
}
