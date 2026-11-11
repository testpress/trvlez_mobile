import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/core/widgets/app_card.dart';

// Experimental local-only golden pilot.
//
// Gated (skip: true) until the golden feasibility gate in
// docs/engineering/playbook/05-visual-validation-standard.md passes:
// - Pin Flutter SDK version in CI (currently unpinned `stable`)
// - Configure deterministic fonts via test/flutter_test_config.dart
// - Generate and review baseline PNG in the pinned environment
void main() {
  testGoldens('AppCard preserves padding and text wrapping at supported scales', (
    tester,
  ) async {
    const card = AppCard(
      child: Text(
        'Reservation details remain readable when the system text scale grows.',
      ),
    );

    final builder = GoldenBuilder.column()
      ..addScenario('normal text', card)
      ..addTextScaleScenario('large text', card, textScaleFactor: 1.5);

    await tester.pumpWidgetBuilder(
      builder.build(),
      wrapper: materialAppWrapper(theme: AppTheme.lightTheme),
      surfaceSize: const Size(360, 460),
    );

    await screenMatchesGolden(tester, 'app_card_scales');
  }, skip: true);
}
