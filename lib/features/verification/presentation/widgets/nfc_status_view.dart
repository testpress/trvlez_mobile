import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Informational view shown when NFC hardware is either disabled or unsupported.
class NfcStatusView extends StatelessWidget {
  final bool isDisabled;
  final VoidCallback onSkipNfc;

  const NfcStatusView({
    super.key,
    required this.isDisabled,
    required this.onSkipNfc,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          Icons.nfc_rounded,
          size: 80,
          color: theme.colorScheme.onSurface.withAlpha(100),
        ),
        const SizedBox(height: 24),
        Text(
          isDisabled ? 'NFC is Disabled' : 'NFC Not Available',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isDisabled
              ? 'Please enable NFC in your device settings to scan your passport. We will automatically resume once it is enabled.'
              : 'Your device either does not support NFC or it is currently disabled. You can continue verification without NFC.',
          textAlign: TextAlign.center,
          style: context.text.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(180),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 48),
        if (isDisabled) ...[
          FilledButton(
            onPressed: () {
              AppSettings.openAppSettings(type: AppSettingsType.nfc);
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
            ),
            child: const Text('Enable NFC'),
          ),
          const SizedBox(height: 12),
        ],
        if (!isDisabled) ...[
          FilledButton(
            onPressed: onSkipNfc,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
            ),
            child: const Text('Continue Without NFC'),
          ),
        ] else ...[
          TextButton(
            onPressed: onSkipNfc,
            child: const Text('Continue Without NFC'),
          ),
        ],
      ],
    );
  }
}
