import 'package:flutter/material.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/confirm_details_screen.dart';

export 'confirm_details_screen.dart';

/// Backward-compatible alias for [ConfirmDetailsScreen].
class MrzReviewScreen extends StatelessWidget {
  const MrzReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ConfirmDetailsScreen();
  }
}
