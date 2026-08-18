import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

/// A shared service for camera and image picking capabilities.
class CameraService {
  final ImagePicker _picker = ImagePicker();

  /// Initializes the camera with the specified parameters.
  Future<CameraController?> initCamera({
    required CameraLensDirection lensDirection,
    ResolutionPreset resolution = ResolutionPreset.max,
    bool enableAudio = false,
  }) async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return null;

    final camera = cameras.firstWhere(
      (c) => c.lensDirection == lensDirection,
      orElse: () => cameras.first,
    );

    final controller = CameraController(
      camera,
      resolution,
      enableAudio: enableAudio,
    );

    await controller.initialize();
    return controller;
  }

  /// Picks an image from the device gallery.
  Future<File?> pickImageFromGallery() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    return image != null ? File(image.path) : null;
  }

  /// Picks a video from the device gallery.
  Future<File?> pickVideoFromGallery() async {
    final video = await _picker.pickVideo(source: ImageSource.gallery);
    return video != null ? File(video.path) : null;
  }
}
