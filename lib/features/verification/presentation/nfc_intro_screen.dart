import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:trvlez_mobile/features/verification/presentation/verification_notifier.dart';import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_progress_bar.dart';
/// Screen that introduces the NFC passport reading feature to the user.
/// Explains the benefits and requirements, offering options to proceed or skip.
class NfcIntroScreen extends StatelessWidget {
  final VerificationNotifier notifier;

  const NfcIntroScreen({
    super.key,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Read Passport Chip'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            // Usually we shouldn't pop if we're in a linear flow, but allow going back to selfie review.
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/verification/selfie-review');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step progress bar — NFC is step 4
              VerificationProgressBar.verification(currentStepIndex: 3),
              const SizedBox(height: 8),
              // Illustration / Icon
              Expanded(
                flex: 2,
                child: Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 64,
                          color: theme.colorScheme.onPrimaryContainer.withAlpha(150),
                        ),
                        Positioned(
                          right: 32,
                          bottom: 32,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.nfc_rounded,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Text Content
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Text(
                      'Verify with NFC',
                      style: GoogleFonts.nunito(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your passport has a secure microchip inside. Scanning it provides the highest level of security and speeds up your verification.',
                      style: GoogleFonts.cabin(
                        fontSize: 16,
                        color: theme.colorScheme.onSurface.withAlpha(180),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    // Instructions
                    _buildInstructionRow(
                      context, 
                      Icons.book_rounded, 
                      'Look for the ePassport symbol ✈️ on the cover.',
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionRow(
                      context, 
                      Icons.smartphone_rounded, 
                      'You may need to remove thick phone cases.',
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionRow(
                      context, 
                      Icons.timer_rounded, 
                      'It usually takes about 10-15 seconds.',
                    ),
                  ],
                ),
              ),
              
              // Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      context.push('/verification/nfc-scan');
                    },
                    icon: const Icon(Icons.nfc_rounded),
                    label: const Text('Start NFC Scan'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      _showSkipConfirmation(context);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Skip this step',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withAlpha(150),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 24,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.cabin(
              fontSize: 15,
              color: theme.colorScheme.onSurface.withAlpha(200),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  void _showSkipConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip NFC Scan?'),
        content: const Text(
          'Skipping NFC means we will rely solely on your passport photo. This may lower your verification confidence score and require manual review.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              notifier.skipNfc();
              // Proceed directly to submission
              notifier.submitVerificationAsync();
              context.go('/verification/status');
            },
            child: const Text('Skip Anyway'),
          ),
        ],
      ),
    );
  }
}
