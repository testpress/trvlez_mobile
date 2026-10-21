/// Named text scale presets for TRVLez, ported from ezChat.
///
/// Applied app-wide via [MediaQuery.textScaler] and capped at 1.3x so
/// fixed-height widgets (passes, booking cards) do not overflow.
enum TextScalePreset {
  smaller(scaleFactor: 0.88, label: 'Smaller', sampleSize: 13.0),
  normal(scaleFactor: 1.0, label: 'Normal', sampleSize: 15.0),
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

  static TextScalePreset fromName(String? name) {
    return switch (name) {
      'smaller' => TextScalePreset.smaller,
      'larger' => TextScalePreset.larger,
      'largest' => TextScalePreset.largest,
      _ => TextScalePreset.normal,
    };
  }
}
