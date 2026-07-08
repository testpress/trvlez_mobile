/// Represents the distinct steps in the NFC passport reading process.
enum NfcReadStep {
  connecting,
  readingCardAccess,
  authenticating,
  readingCom,
  readingDg1,
  readingDg2,
  readingDg14,
  readingDg15,
  activeAuthentication,
  readingSod,
  complete,
}

/// Emitted periodically to update the UI on the current read progress.
class NfcReadProgress {
  final NfcReadStep currentStep;
  final double percentage;
  final String description;

  const NfcReadProgress({
    required this.currentStep,
    required this.percentage,
    required this.description,
  });

  /// Returns a copy of this progress with updated fields.
  NfcReadProgress copyWith({
    NfcReadStep? currentStep,
    double? percentage,
    String? description,
  }) {
    return NfcReadProgress(
      currentStep: currentStep ?? this.currentStep,
      percentage: percentage ?? this.percentage,
      description: description ?? this.description,
    );
  }
}
