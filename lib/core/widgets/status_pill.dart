import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Supported status states for booking and workflow status pills.
enum StatusPillState { confirmed, awaiting, completed, cancelled }

/// Status badge pill with curated semantic tokens conforming to the design system.
///
/// **Contract:**
/// - **Owner:** Core workflow and reservation status badge (`lib/core/widgets/status_pill.dart`).
/// - **Variants:** [StatusPillState.confirmed], [StatusPillState.awaiting],
///   [StatusPillState.completed], and [StatusPillState.cancelled].
/// - **States:** Static display surface with semantic token pairings.
/// - **Accessibility:** Uses high-contrast semantic color pairings for readability; text scaling supported.
/// - **Validation Owner:** `test/core/widgets/status_pill_test.dart`.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.state});

  final String label;
  final StatusPillState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;

    final (fill, ink) = switch (state) {
      StatusPillState.confirmed => (colors.okFill, colors.okInk),
      StatusPillState.awaiting => (colors.waitFill, colors.waitInk),
      StatusPillState.completed => (colors.page, colors.inkTertiary),
      StatusPillState.cancelled => (colors.redTint, colors.brandPrimary),
    };

    return Container(
      padding: space.insetTag,
      decoration: BoxDecoration(color: fill, borderRadius: shape.radiusPill),
      child: Text(
        label,
        style: context.text.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: ink,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
