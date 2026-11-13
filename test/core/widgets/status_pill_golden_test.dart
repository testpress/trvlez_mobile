import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/core/widgets/status_pill.dart';

// Golden test verifying StatusPill visual states and text scaling.
//
// Governed by docs/engineering/playbook/05-visual-validation-standard.md.
// Uses deterministic fonts configured in test/flutter_test_config.dart.
void main() {
  testGoldens(
    'StatusPill preserves colors, pill shape, and text scaling across states',
    (tester) async {
      const pills = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusPill(label: 'CONFIRMED', state: StatusPillState.confirmed),
          SizedBox(height: 8),
          StatusPill(label: 'AWAITING', state: StatusPillState.awaiting),
          SizedBox(height: 8),
          StatusPill(label: 'COMPLETED', state: StatusPillState.completed),
          SizedBox(height: 8),
          StatusPill(label: 'CANCELLED', state: StatusPillState.cancelled),
        ],
      );

      final builder = GoldenBuilder.column()
        ..addScenario('normal scale', pills)
        ..addTextScaleScenario('large text scale', pills, textScaleFactor: 1.5);

      await tester.pumpWidgetBuilder(
        builder.build(),
        wrapper: materialAppWrapper(theme: AppTheme.lightTheme),
        surfaceSize: const Size(360, 480),
      );

      await screenMatchesGolden(tester, 'status_pill_states');
    },
    tags: ['golden'],
  );
}
