import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_app.dart';
import 'viewport_testing.dart';

final _sampleLabelProvider = Provider<String>((ref) => 'default');

void main() {
  group('TestApp & viewport helpers', () {
    testWidgets('TestApp injects textScaler inside MaterialApp MediaQuery', (
      tester,
    ) async {
      TextScaler? observedScaler;

      await tester.pumpWidget(
        TestApp(
          textScaler: TestTextScales.accessibility,
          child: Builder(
            builder: (context) {
              observedScaler = MediaQuery.textScalerOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(observedScaler, TestTextScales.accessibility);
    });

    testWidgets('testAppWithProviders applies Riverpod overrides and locale', (
      tester,
    ) async {
      String? observedLabel;
      Locale? observedLocale;

      await tester.pumpWidget(
        testAppWithProviders(
          overrides: [_sampleLabelProvider.overrideWithValue('overridden')],
          locale: const Locale('en', 'GB'),
          child: Consumer(
            builder: (context, ref, _) {
              observedLabel = ref.watch(_sampleLabelProvider);
              observedLocale = Localizations.localeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(observedLabel, 'overridden');
      expect(observedLocale, const Locale('en', 'GB'));
    });

    testWidgets('ViewportTesting sets and resets logical viewport size', (
      tester,
    ) async {
      Size? observedSize;

      tester.setViewport(TestViewports.compactAndroid);
      addTearDown(tester.resetViewport);

      await tester.pumpWidget(
        TestApp(
          child: Builder(
            builder: (context) {
              observedSize = MediaQuery.sizeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(observedSize, TestViewports.compactAndroid);
    });

    final seenViewports = <Size>[];
    testViewportMatrix(
      'testViewportMatrix iterates every Android viewport',
      viewports: TestViewports.androidAll,
      builder: (tester, viewport) async {
        Size? observedSize;
        await tester.pumpWidget(
          TestApp(
            child: Builder(
              builder: (context) {
                observedSize = MediaQuery.sizeOf(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        expect(observedSize, viewport);
        seenViewports.add(viewport);
      },
    );

    test('testViewportMatrix covered all androidAll entries', () {
      expect(seenViewports, TestViewports.androidAll);
    });

    final seenScales = <double>[];
    testTextScaleMatrix(
      'testTextScaleMatrix iterates every configured text scale',
      viewport: TestViewports.compactAndroid,
      scales: const [
        TestTextScales.normal,
        TestTextScales.large,
        TestTextScales.accessibility,
      ],
      builder: (tester, scale) async {
        TextScaler? observedScaler;
        await tester.pumpWidget(
          TestApp(
            textScaler: scale,
            child: Builder(
              builder: (context) {
                observedScaler = MediaQuery.textScalerOf(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        expect(observedScaler, scale);
        seenScales.add(scale.scale(1.0));
      },
    );

    test('testTextScaleMatrix covered all configured scales', () {
      expect(seenScales, [1.0, 1.3, 2.0]);
    });

    testWidgets('setInsetProfile exposes padding/viewPadding/viewInsets', (
      tester,
    ) async {
      EdgeInsets? observedPadding;
      EdgeInsets? observedViewPadding;
      EdgeInsets? observedViewInsets;

      tester.setViewport(TestViewports.compactAndroid);
      tester.setInsetProfile(TestInsetProfiles.keyboardOpen);
      addTearDown(tester.resetViewport);

      await tester.pumpWidget(
        TestApp(
          child: Builder(
            builder: (context) {
              observedPadding = MediaQuery.paddingOf(context);
              observedViewPadding = MediaQuery.viewPaddingOf(context);
              observedViewInsets = MediaQuery.viewInsetsOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(observedPadding, const EdgeInsets.only(top: 24));
      expect(observedViewPadding, const EdgeInsets.only(top: 24, bottom: 48));
      expect(observedViewInsets, const EdgeInsets.only(bottom: 300));
    });

    testWidgets('SafeArea consumes gesture-nav bottom inset', (tester) async {
      Size? safeChildSize;

      tester.setViewport(const Size(360, 640));
      tester.setInsetProfile(TestInsetProfiles.androidGestureNav);
      addTearDown(tester.resetViewport);

      await tester.pumpWidget(
        TestApp(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                safeChildSize = Size(
                  constraints.maxWidth,
                  constraints.maxHeight,
                );
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      );

      // 640 logical height minus top 24 and bottom 48 gesture inset.
      expect(safeChildSize, const Size(360, 568));
    });

    final seenInsetNames = <String>[];
    testInsetMatrix(
      'testInsetMatrix iterates configured inset profiles',
      viewport: TestViewports.compactAndroid,
      profiles: const [
        TestInsetProfiles.androidGestureNav,
        TestInsetProfiles.keyboardOpen,
      ],
      builder: (tester, profile) async {
        EdgeInsets? observedViewInsets;
        await tester.pumpWidget(
          TestApp(
            child: Builder(
              builder: (context) {
                observedViewInsets = MediaQuery.viewInsetsOf(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        if (profile.name == TestInsetProfiles.keyboardOpen.name) {
          expect(observedViewInsets, const EdgeInsets.only(bottom: 300));
        } else {
          expect(observedViewInsets, EdgeInsets.zero);
        }
        seenInsetNames.add(profile.name);
      },
    );

    test('testInsetMatrix covered configured profiles', () {
      expect(seenInsetNames, [
        TestInsetProfiles.androidGestureNav.name,
        TestInsetProfiles.keyboardOpen.name,
      ]);
    });
  });
}
