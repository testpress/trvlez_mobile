import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_motion.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/palette.dart';

void main() {
  group('Theme Tokens & Primitives', () {
    test('Palette primitives have valid colors', () {
      expect(Palette.red600, const Color(0xFFD61F26));
      expect(Palette.neutral0, const Color(0xFFFFFFFF));
      expect(Palette.green600, const Color(0xFF16A34A));
    });

    test('AppSpacing maintains 4-pt grid system', () {
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.sm, 8.0);
      expect(AppSpacing.md, 16.0);
      expect(AppSpacing.lg, 24.0);
      expect(AppSpacing.xl, 32.0);
      expect(AppSpacing.xxl, 48.0);
      expect(AppSpacing.screenPadding, AppSpacing.md);
    });

    test('AppRadius provides standardized border radiuses', () {
      expect(AppRadius.card, BorderRadius.circular(24.0));
      expect(AppRadius.button, BorderRadius.circular(12.0));
      expect(AppRadius.input, BorderRadius.circular(12.0));
    });

    test('AppMotion provides standard durations and curves', () {
      expect(AppMotion.fast, const Duration(milliseconds: 150));
      expect(AppMotion.normal, const Duration(milliseconds: 250));
      expect(AppMotion.slow, const Duration(milliseconds: 400));
      expect(AppMotion.curve, Curves.easeOutCubic);
    });

    test('AppColors ThemeExtension copyWith and lerp', () {
      const colors = AppColors.light;
      final copied = colors.copyWith(actionPrimary: Colors.purple);
      expect(copied.actionPrimary, Colors.purple);
      expect(copied.surface, colors.surface);

      final lerped = colors.lerp(AppColors.dark, 0.5);
      expect(lerped, isA<AppColors>());
      expect(colors.lerp(null, 0.5), colors);
    });

    testWidgets(
      'AppTheme registers AppColors extension and context.colors resolves',
      (tester) async {
        late AppColors activeColors;
        late TextTheme activeText;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Builder(
              builder: (context) {
                activeColors = context.colors;
                activeText = context.text;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(activeColors.actionPrimary, AppColors.light.actionPrimary);
        expect(activeColors.surface, AppColors.light.surface);
        expect(activeText.bodyMedium, isNotNull);
      },
    );

    test('AppSpace ThemeExtension copyWith and lerp', () {
      const space = AppSpace.comfortable;
      final copied = space.copyWith(stackFormField: 20.0);
      expect(copied.stackFormField, 20.0);
      expect(copied.insetCard, space.insetCard);

      final lerped = space.lerp(AppSpace.compact, 0.5);
      expect(lerped, isA<AppSpace>());
      expect(space.lerp(null, 0.5), space);
    });

    test('AppSize ThemeExtension copyWith and lerp', () {
      const size = AppSize.regular;
      final copied = size.copyWith(iconDefault: 26.0);
      expect(copied.iconDefault, 26.0);
      expect(copied.controlLg, size.controlLg);

      final lerped = size.lerp(size, 0.5);
      expect(lerped, isA<AppSize>());
      expect(size.lerp(null, 0.5), size);
    });

    test('AppShape ThemeExtension copyWith, lerp, and inner radius', () {
      const shape = AppShape.standard;
      final copied = shape.copyWith(borderDefault: 1.2);
      expect(copied.borderDefault, 1.2);
      expect(copied.radiusSurface, shape.radiusSurface);

      final lerped = shape.lerp(shape, 0.5);
      expect(lerped, isA<AppShape>());
      expect(shape.lerp(null, 0.5), shape);

      final innerRadius = shape.inner(
        const BorderRadius.all(Radius.circular(16)),
        const EdgeInsets.all(4),
      );
      expect(innerRadius.topLeft.x, 12.0);
    });

    testWidgets(
      'AppTheme registers AppSpace, AppSize, and AppShape on context',
      (tester) async {
        late AppSpace space;
        late AppSize size;
        late AppShape shape;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Builder(
              builder: (context) {
                space = context.space;
                size = context.sizes;
                shape = context.shape;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(space.insetCard, const EdgeInsets.all(16.0));
        expect(space.stackFormField, 16.0);
        expect(size.controlLg, 48.0);
        expect(size.iconDefault, 24.0);
        expect(
          shape.radiusSurface,
          const BorderRadius.all(Radius.circular(16.0)),
        );
        expect(shape.borderDefault, 1.0);
      },
    );
  });
}
