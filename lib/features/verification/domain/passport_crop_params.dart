/// Parameter model carrying framing metadata required to crop the passport region
/// from the raw full-frame camera capture.
class PassportCropParams {
  final String imagePath;
  final double screenWidth;
  final double screenHeight;
  final double frameWidth;
  final double frameHeight;
  final double frameCenterX;
  final double? frameCenterY;

  /// The camera preview's aspect ratio (width / height) as reported by the
  /// camera controller. Used to correctly map overlay-frame screen coordinates
  /// to captured-image pixel coordinates when the preview and captured image
  /// have different aspect ratios (e.g. 16:9 preview vs 4:3 capture).
  final double? previewAspectRatio;

  const PassportCropParams({
    required this.imagePath,
    required this.screenWidth,
    required this.screenHeight,
    required this.frameWidth,
    required this.frameHeight,
    required this.frameCenterX,
    this.frameCenterY,
    this.previewAspectRatio,
  });

  Map<String, dynamic> toMap() => {
    'path': imagePath,
    'sw': screenWidth,
    'sh': screenHeight,
    'frameWidth': frameWidth,
    'frameHeight': frameHeight,
    'frameCenterX': frameCenterX,
    if (frameCenterY != null) 'frameCenterY': frameCenterY,
    'previewAR': previewAspectRatio,
  };

  factory PassportCropParams.fromMap(Map<String, dynamic> map) {
    return PassportCropParams(
      imagePath: map['path'] as String,
      screenWidth: (map['sw'] as num).toDouble(),
      screenHeight: (map['sh'] as num).toDouble(),
      frameWidth: (map['frameWidth'] as num).toDouble(),
      frameHeight: (map['frameHeight'] as num).toDouble(),
      frameCenterX: (map['frameCenterX'] as num).toDouble(),
      frameCenterY: (map['frameCenterY'] as num?)?.toDouble(),
      previewAspectRatio: (map['previewAR'] as num?)?.toDouble(),
    );
  }
}
