import 'package:flutter/material.dart';
import 'package:trvlez_mobile/core/widgets/verification_stepper.dart';

/// Legacy adapter for [VerificationStepper] ensuring full backwards compatibility.
class KycProgressStepper extends StatelessWidget {
  const KycProgressStepper({super.key, required this.progressIndex});

  final int progressIndex;

  @override
  Widget build(BuildContext context) {
    return VerificationStepper(current: progressIndex);
  }
}
