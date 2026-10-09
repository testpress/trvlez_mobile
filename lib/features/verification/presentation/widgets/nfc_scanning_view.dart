import 'dart:io';

import 'package:flutter/material.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_read_progress.dart';

/// Active scanning view with contactless pulse animation and progress indicator.
class NfcScanningView extends StatelessWidget {
  final Animation<double> pulseAnimation;
  final NfcReadProgress? currentProgress;

  const NfcScanningView({
    super.key,
    required this.pulseAnimation,
    required this.currentProgress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = currentProgress?.percentage ?? 0.0;
    final description = currentProgress?.description ?? 'Preparing...';

    return Column(
      children: [
        AnimatedBuilder(
          animation: pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: pulseAnimation.value,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primaryContainer,
                  border: Border.all(
                    color: theme.colorScheme.primary.withAlpha(50),
                    width: 8,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.contactless_rounded,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 48),
        Text(
          description,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        LinearProgressIndicator(
          value: progress > 0 ? progress : null,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 16),
        Text(
          'Keep your phone steady against the passport',
          style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer.withAlpha(100),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Platform.isIOS
                    ? Icons.phone_iphone_rounded
                    : Icons.android_rounded,
                color: theme.colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  Platform.isIOS
                      ? 'Rest the top edge of your iPhone on the inside back cover of the passport.'
                      : 'Place the middle/top of your phone flat against the passport data page.',
                  style: TextStyle(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
