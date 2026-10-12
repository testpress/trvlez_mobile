import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

/// Supported status states for booking and workflow status pills.
enum StatusPillState { confirmed, awaiting, completed, cancelled }

/// Status badge pill with curated semantic tokens conforming to the design system.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.state});

  final String label;
  final StatusPillState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final (fill, ink) = switch (state) {
      StatusPillState.confirmed => (colors.okFill, colors.okInk),
      StatusPillState.awaiting => (colors.waitFill, colors.waitInk),
      StatusPillState.completed => (colors.page, colors.inkTertiary),
      StatusPillState.cancelled => (colors.redTint, colors.brandPrimary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: AppRadius.fullRadius,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 10,
          fontWeight: TypeScale.semiBold,
          color: ink,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
