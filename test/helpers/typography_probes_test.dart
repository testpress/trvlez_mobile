import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'typography_probes.dart';

class _NonlinearTestScaler implements TextScaler {
  const _NonlinearTestScaler();

  @override
  double scale(double fontSize) {
    if (fontSize <= 12) return fontSize * 1.5;
    if (fontSize <= 16) return fontSize * 1.3;
    if (fontSize <= 20) return fontSize * 1.15;
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
  group('TypographyProbeSet Tests', () {
    test('probes linear scaler accurately', () {
      const linearScaler = TextScaler.linear(1.5);
      final probes = TypographyProbeSet.fromScaler(linearScaler);

      expect(probes.scale12, closeTo(18.0, 0.001));
      expect(probes.scale16, closeTo(24.0, 0.001));
      expect(probes.scale20, closeTo(30.0, 0.001));
      expect(probes.scale24, closeTo(36.0, 0.001));
      expect(probes.isLinear, isTrue);

      final json = probes.toJson();
      expect(json['is_linear'], isTrue);
      expect(json['scale_12'], closeTo(18.0, 0.001));
    });

    test('detects nonlinear scaling and preserves probe points', () {
      const nonlinear = _NonlinearTestScaler();
      final probes = TypographyProbeSet.fromScaler(nonlinear);

      expect(probes.scale12, closeTo(18.0, 0.001)); // 12 * 1.5
      expect(probes.scale16, closeTo(20.8, 0.001)); // 16 * 1.3
      expect(probes.scale20, closeTo(23.0, 0.001)); // 20 * 1.15
      expect(probes.scale24, closeTo(24.0, 0.001)); // 24 * 1.0
      expect(probes.isLinear, isFalse);
    });

    test('formatPairedRows outputs ADR 0002 markdown table', () {
      final a = TypographyProbeSet.fromScaler(const TextScaler.linear(1.0));
      final b = TypographyProbeSet.fromScaler(const _NonlinearTestScaler());

      final table = TypographyProbeSet.formatPairedRows(
        deviceAName: 'realme 8',
        deviceA: a,
        deviceBName: 'Pixel 10a',
        deviceB: b,
      );

      expect(table, contains('| Field | realme 8 | Pixel 10a |'));
      expect(table, contains('| `textScaler.scale(12)` | 12.00 | 18.00 |'));
      expect(table, contains('| `textScaler.scale(24)` | 24.00 | 24.00 |'));
    });
  });
}
