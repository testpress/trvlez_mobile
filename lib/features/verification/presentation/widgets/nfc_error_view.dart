import 'package:flutter/material.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_error.dart';

/// Error state view for NFC reading failures with user guidance and recovery actions.
class NfcErrorView extends StatelessWidget {
  final NfcError error;
  final VoidCallback onRetry;
  final VoidCallback onRescanPassport;
  final VoidCallback onSkipNfc;

  const NfcErrorView({
    super.key,
    required this.error,
    required this.onRetry,
    required this.onRescanPassport,
    required this.onSkipNfc,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userGuidance = error.userGuidance;
    final technicalDetails = error.technicalDetails;

    return Column(
      children: [
        Icon(
          Icons.error_outline_rounded,
          size: 80,
          color: theme.colorScheme.error,
        ),
        const SizedBox(height: 24),
        Text(
          'Scan Failed',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          error.message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: theme.colorScheme.onSurface.withAlpha(180),
            height: 1.5,
          ),
        ),
        if (userGuidance != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withAlpha(80),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 20,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    userGuidance,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSecondaryContainer,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (technicalDetails != null) ...[
          const SizedBox(height: 8),
          Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(
                'Technical Details',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withAlpha(100),
                ),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withAlpha(
                      100,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SelectableText(
                    technicalDetails,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurface.withAlpha(120),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 32),
        if (error.isRetryable)
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
            ),
          )
        else if (error.type == NfcErrorType.authenticationFailed ||
            error.type == NfcErrorType.invalidMrzData)
          FilledButton.icon(
            onPressed: onRescanPassport,
            icon: const Icon(Icons.document_scanner_rounded),
            label: const Text('Re-scan Passport Photo'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: onSkipNfc,
          child: const Text('Skip NFC Verification'),
        ),
      ],
    );
  }
}
