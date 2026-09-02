/// Parameter model carrying framing metadata required to crop the passport region
/// from the raw full-frame camera capture.
class PassportCropParams {
  final String imagePath;
  final double screenWidth;
  final double screenHeight;
  final double frameWidth;
  final double frameHeight;
  final double frameCenterX;

  const PassportCropParams({
    required this.imagePath,
    required this.screenWidth,
    required this.screenHeight,
    required this.frameWidth,
    required this.frameHeight,
    required this.frameCenterX,
  });

  Map<String, dynamic> toMap() => {
    'path': imagePath,
    'sw': screenWidth,
    'sh': screenHeight,
    'frameWidth': frameWidth,
    'frameHeight': frameHeight,
    'frameCenterX': frameCenterX,
  };

  factory PassportCropParams.fromMap(Map<String, dynamic> map) {
    return PassportCropParams(
      imagePath: map['path'] as String,
      screenWidth: map['sw'] as double,
      screenHeight: map['sh'] as double,
      frameWidth: map['frameWidth'] as double,
      frameHeight: map['frameHeight'] as double,
      frameCenterX: map['frameCenterX'] as double,
    );
  }
}
