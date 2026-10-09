import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/domain/traveler_verification_state.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/verification_status_config.dart';

/// Central animated status badge on the verification status screen.
class VerificationStatusIcon extends StatelessWidget {
  final StatusConfig config;
  final TravelerVerificationState state;
  final Animation<double> pulseAnimation;

  const VerificationStatusIcon({
    super.key,
    required this.config,
    required this.state,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final icon = Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: config.iconGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: config.iconGradient.first.withAlpha(60),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(config.icon, color: context.colors.textOnAction, size: 44),
    );

    if (state.isProcessing) {
      return AnimatedBuilder(
        animation: pulseAnimation,
        builder: (context, child) {
          return Transform.scale(scale: pulseAnimation.value, child: child);
        },
        child: icon,
      );
    }

    return icon;
  }
}
