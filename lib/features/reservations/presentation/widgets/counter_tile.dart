import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';

class CounterTile extends StatelessWidget {
  final String label;
  final String? subtitle;
  final Color? subtitleColor;
  final IconData icon;
  final int value;
  final ColorScheme colorScheme;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const CounterTile({
    super.key,
    required this.label,
    this.subtitle,
    this.subtitleColor,
    required this.icon,
    required this.value,
    required this.colorScheme,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: subtitleColor ?? colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCounterButton(Icons.remove, onDecrement, colorScheme),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$value',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              _buildCounterButton(Icons.add, onIncrement, colorScheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton(
    IconData icon,
    VoidCallback? onTap,
    ColorScheme colorScheme,
  ) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isEnabled
              ? colorScheme.primary.withAlpha(26)
              : colorScheme.surfaceContainerHighest,
          borderRadius: AppRadius.smRadius,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isEnabled
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant.withAlpha(100),
        ),
      ),
    );
  }
}
