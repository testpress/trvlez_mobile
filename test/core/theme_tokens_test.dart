import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_motion.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/palette.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';

void main() {
  group('Theme Tokens & Primitives', () {
    test('Palette primitives have valid colors', () {
      expect(Palette.red600, const Color(0xFFD61F26));
      expect(Palette.neutral0, const Color(0xFFFFFFFF));
      expect(Palette.green600, const Color(0xFF16A34A));
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
        expect(activeText.headlineLarge?.fontSize, TypeScale.s26);
        expect(activeText.bodyLarge?.fontSize, TypeScale.s16);
      },
    );

    test('AppTypography provides brand heading and subtitle tokens', () {
      expect(AppTypography.brandHeading.fontSize, TypeScale.s26);
      expect(AppTypography.brandHeading.fontWeight, TypeScale.bold);
      expect(AppTypography.brandSubtitle.fontSize, TypeScale.s16);
      expect(AppTypography.brandSubtitle.fontWeight, TypeScale.medium);
    });

    test('AppSpace ThemeExtension copyWith and lerp', () {
      const space = AppSpace.comfortable;
      final copied = space.copyWith(
        stackFormField: 20.0,
        insetBrandScreen: const EdgeInsets.symmetric(
          horizontal: 28,
          vertical: 20,
        ),
      );
      expect(copied.stackFormField, 20.0);
      expect(
        copied.insetBrandScreen,
        const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      );
      expect(copied.insetCard, space.insetCard);
      expect(
        space.insetControlXl,
        const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      );

      final lerped = space.lerp(AppSpace.compact, 0.5);
      expect(lerped, isA<AppSpace>());
      expect(space.lerp(null, 0.5), space);
    });

    test('AppSize ThemeExtension copyWith and lerp', () {
      const size = AppSize.regular;
      final copied = size.copyWith(
        iconDefault: 26.0,
        controlHero: 80.0,
        containerPhone: 440.0,
        cardHeightCarousel: 230.0,
      );
      expect(copied.iconDefault, 26.0);
      expect(copied.controlLg, size.controlLg);
      expect(copied.controlHero, 80.0);
      expect(size.controlHero, 72.0);
      expect(copied.containerPhone, 440.0);
      expect(size.iconMicro, 12.0);
      expect(size.cardHeightCarousel, 226.0);
      expect(copied.cardHeightCarousel, 230.0);
      expect(size.previewDocWidth, 200.0);
      expect(size.previewDocHeight, 140.0);
      expect(size.previewDocMaxHeight, 280.0);
      expect(size.containerViewfinder, 320.0);
      expect(size.containerForm, 480.0);

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
