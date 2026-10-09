import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';

/// Top bar overlay displaying close button and flash cycle toggle.
class PassportTopBar extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onToggleFlash;
  final FlashMode flashMode;
  final EdgeInsets padding;

  const PassportTopBar({
    super.key,
    required this.onClose,
    required this.onToggleFlash,
    required this.flashMode,
    required this.padding,
  });

  IconData get _flashIcon => switch (flashMode) {
    FlashMode.off => Icons.flash_off,
    FlashMode.auto => Icons.flash_auto,
    FlashMode.torch || FlashMode.always => Icons.flash_on,
  };

  String get _flashLabel => switch (flashMode) {
    FlashMode.off => 'Off',
    FlashMode.auto => 'Auto',
    FlashMode.torch || FlashMode.always => 'On',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      top: padding.top + 8,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: onClose,
          ),
          GestureDetector(
            onTap: onToggleFlash,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(100),
                borderRadius: AppRadius.lg20Radius,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_flashIcon, color: Colors.white, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    _flashLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
