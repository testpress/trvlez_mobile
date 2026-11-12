import 'package:flutter/widgets.dart';

/// Typography probe points specified by ADR 0002 and playbook chapter 06.
abstract final class TypographyProbePoints {
  static const double caption = 12.0;
  static const double body = 16.0;
  static const double subhead = 20.0;
  static const double title = 24.0;

  static const List<double> standard = [caption, body, subhead, title];
}

/// Recorded probe values for evaluating typography scaling strategies (ADR 0002).
///
/// Probes at 12, 16, 20, and 24 logical pixels without modifying production layout.
@immutable
class TypographyProbeSet {
  const TypographyProbeSet({
    required this.strategy,
    required this.scale12,
    required this.scale16,
    required this.scale20,
    required this.scale24,
  });

  factory TypographyProbeSet.fromScaler(TextScaler scaler) {
    return TypographyProbeSet(
      strategy: scaler.toString(),
      scale12: scaler.scale(TypographyProbePoints.caption),
      scale16: scaler.scale(TypographyProbePoints.body),
      scale20: scaler.scale(TypographyProbePoints.subhead),
      scale24: scaler.scale(TypographyProbePoints.title),
    );
  }

  factory TypographyProbeSet.fromContext(BuildContext context) {
    return TypographyProbeSet.fromScaler(MediaQuery.textScalerOf(context));
  }

  final String strategy;
  final double scale12;
  final double scale16;
  final double scale20;
  final double scale24;

  /// Whether the scaler is purely linear across the probe points.
  bool get isLinear {
    final r12 = scale12 / 12.0;
    final r16 = scale16 / 16.0;
    final r20 = scale20 / 20.0;
    final r24 = scale24 / 24.0;
    const epsilon = 0.001;
    return (r12 - r16).abs() < epsilon &&
        (r16 - r20).abs() < epsilon &&
        (r20 - r24).abs() < epsilon;
  }

  Map<String, dynamic> toJson() => {
    'strategy': strategy,
    'scale_12': scale12,
    'scale_16': scale16,
    'scale_20': scale20,
    'scale_24': scale24,
    'is_linear': isLinear,
  };

  /// Generates the ADR 0002 / Chapter 06 paired-device typography table rows.
  static String formatPairedRows({
    required String deviceAName,
    required TypographyProbeSet deviceA,
    required String deviceBName,
    required TypographyProbeSet deviceB,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('| Field | $deviceAName | $deviceBName |');
    buffer.writeln('| --- | --- | --- |');
    buffer.writeln(
      '| `textScaler` strategy | ${deviceA.strategy} | ${deviceB.strategy} |',
    );
    buffer.writeln(
      '| `textScaler.scale(12)` | ${deviceA.scale12.toStringAsFixed(2)} | ${deviceB.scale12.toStringAsFixed(2)} |',
    );
    buffer.writeln(
      '| `textScaler.scale(16)` | ${deviceA.scale16.toStringAsFixed(2)} | ${deviceB.scale16.toStringAsFixed(2)} |',
    );
    buffer.writeln(
      '| `textScaler.scale(20)` | ${deviceA.scale20.toStringAsFixed(2)} | ${deviceB.scale20.toStringAsFixed(2)} |',
    );
    buffer.writeln(
      '| `textScaler.scale(24)` | ${deviceA.scale24.toStringAsFixed(2)} | ${deviceB.scale24.toStringAsFixed(2)} |',
    );
    return buffer.toString();
  }
}
