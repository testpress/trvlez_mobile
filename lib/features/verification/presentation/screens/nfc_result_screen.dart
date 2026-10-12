import 'package:flutter/material.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/chip_data_screen.dart';

export 'chip_data_screen.dart';

/// Backward-compatible alias for [ChipDataScreen].
class NfcResultScreen extends StatelessWidget {
  const NfcResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChipDataScreen();
  }
}
