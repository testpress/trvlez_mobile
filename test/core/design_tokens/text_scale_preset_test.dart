import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/core/design_tokens/text_scale_preset.dart';

class _NonlinearScaler implements TextScaler {
  const _NonlinearScaler();

  @override
  double scale(double fontSize) {
    if (fontSize <= 12) return fontSize * 1.5;
    if (fontSize <= 16) return fontSize * 1.3;
    return fontSize * 1.0;
  }

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => 1.3;

  @override
  TextScaler clamp({
    double minScaleFactor = 0.0,
    double maxScaleFactor = double.infinity,
  }) => this;
}

void main() {
  group('TextScalePreset Tests', () {
    test('fromName deserializes presets and falls back to followSystem', () {
      expect(TextScalePreset.fromName('smaller'), TextScalePreset.smaller);
      expect(TextScalePreset.fromName('larger'), TextScalePreset.larger);
      expect(TextScalePreset.fromName('largest'), TextScalePreset.largest);
      expect(
        TextScalePreset.fromName('followSystem'),
        TextScalePreset.followSystem,
      );
      expect(TextScalePreset.fromName('normal'), TextScalePreset.followSystem);
      expect(TextScalePreset.fromName('unknown'), TextScalePreset.followSystem);
      expect(TextScalePreset.fromName(null), TextScalePreset.followSystem);
      expect(TextScalePreset.followSystem.label, 'Normal');
    });

    test(
      'followSystem scalerFor returns the exact platform scaler without modification',
      () {
        const platformScaler = _NonlinearScaler();
        final effective = TextScalePreset.followSystem.scalerFor(
          platformScaler,
        );
        expect(identical(effective, platformScaler), isTrue);
      },
    );

    test(
      'relative presets return RelativeTextScaler that delegates per fontSize',
      () {
        const platformScaler = _NonlinearScaler();
        final effective = TextScalePreset.larger.scalerFor(platformScaler);

        expect(effective, isA<RelativeTextScaler>());
        // scale(12) = 12 * 1.5 * 1.15 = 20.7
        expect(effective.scale(12), closeTo(12 * 1.5 * 1.15, 0.001));
        // scale(16) = 16 * 1.3 * 1.15 = 23.92
        expect(effective.scale(16), closeTo(16 * 1.3 * 1.15, 0.001));
        // scale(20) = 20 * 1.0 * 1.15 = 23.0
        expect(effective.scale(20), closeTo(20 * 1.0 * 1.15, 0.001));
      },
    );
  });

  group('RelativeTextScaler Tests', () {
    test('delegates scale to parent and multiplies by scaleFactor', () {
      const parent = TextScaler.linear(1.2);
      const relative = RelativeTextScaler(parent: parent, scaleFactor: 1.15);

      expect(relative.scale(10.0), closeTo(13.8, 0.001));
      // ignore: deprecated_member_use
      expect(relative.textScaleFactor, closeTo(1.38, 0.001));
    });

    test('clamp delegates to parent clamp', () {
      const parent = TextScaler.linear(1.0);
      const relative = RelativeTextScaler(parent: parent, scaleFactor: 1.2);
      final clamped = relative.clamp(minScaleFactor: 1.0, maxScaleFactor: 1.5);

      expect(clamped, isA<RelativeTextScaler>());
    });

    test('equality and hashCode compare parent and scaleFactor', () {
      const p1 = TextScaler.linear(1.0);
      const p2 = TextScaler.linear(1.2);

      const r1 = RelativeTextScaler(parent: p1, scaleFactor: 1.15);
      const r2 = RelativeTextScaler(parent: p1, scaleFactor: 1.15);
      const r3 = RelativeTextScaler(parent: p2, scaleFactor: 1.15);
      const r4 = RelativeTextScaler(parent: p1, scaleFactor: 1.30);

      expect(r1, equals(r2));
      expect(r1.hashCode, equals(r2.hashCode));
      expect(r1, isNot(equals(r3)));
      expect(r1, isNot(equals(r4)));
    });

    test('toString produces readable description', () {
      const parent = TextScaler.linear(1.0);
      const relative = RelativeTextScaler(parent: parent, scaleFactor: 1.15);
      expect(relative.toString(), contains('relative'));
    });
  });
}
