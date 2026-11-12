import 'package:flutter/widgets.dart';

/// In-app text scale presets conforming to ADR 0002.
///
/// Preserves platform text scaler strategies and nonlinear scaling curves.
enum TextScalePreset {
  smaller(scaleFactor: 0.88, label: 'Smaller', sampleSize: 13.0),
  followSystem(scaleFactor: 1.0, label: 'Normal', sampleSize: 15.0),
  larger(scaleFactor: 1.15, label: 'Larger', sampleSize: 18.0),
  largest(scaleFactor: 1.30, label: 'Largest', sampleSize: 21.0);

  const TextScalePreset({
    required this.scaleFactor,
    required this.label,
    required this.sampleSize,
  });

  final double scaleFactor;
  final String label;
  final double sampleSize;

  /// Returns the effective [TextScaler] for the inherited platform scaler.
  ///
  /// Preserves the platform scaler unchanged for [followSystem]. For relative
  /// adjustments, delegates to the platform scaler at each input size.
  TextScaler scalerFor(TextScaler platformScaler) {
    if (this == TextScalePreset.followSystem || scaleFactor == 1.0) {
      return platformScaler;
    }
    return RelativeTextScaler(parent: platformScaler, scaleFactor: scaleFactor);
  }

  static TextScalePreset fromName(String? name) {
    return switch (name) {
      'smaller' => TextScalePreset.smaller,
      'larger' => TextScalePreset.larger,
      'largest' => TextScalePreset.largest,
      _ => TextScalePreset.followSystem,
    };
  }
}

/// Relative text scaler that delegates to [parent] at each input size,
/// preserving platform nonlinear scaling semantics (ADR 0002).
@immutable
class RelativeTextScaler implements TextScaler {
  const RelativeTextScaler({required this.parent, required this.scaleFactor});

  final TextScaler parent;
  final double scaleFactor;

  @override
  double scale(double fontSize) => parent.scale(fontSize) * scaleFactor;

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => parent.textScaleFactor * scaleFactor;

  @override
  TextScaler clamp({
    double minScaleFactor = 0.0,
    double maxScaleFactor = double.infinity,
  }) {
    return RelativeTextScaler(
      parent: parent.clamp(
        minScaleFactor: minScaleFactor,
        maxScaleFactor: maxScaleFactor,
      ),
      scaleFactor: scaleFactor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RelativeTextScaler &&
          other.parent == parent &&
          other.scaleFactor == scaleFactor;

  @override
  int get hashCode => Object.hash(parent, scaleFactor);

  @override
  String toString() => 'relative (${scaleFactor}x of $parent)';
}
