import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'verification_notifier.dart';

class PassportCaptureScreen extends StatefulWidget {
  final VerificationNotifier notifier;

  const PassportCaptureScreen({super.key, required this.notifier});

  @override
  State<PassportCaptureScreen> createState() => _PassportCaptureScreenState();
}

class _PassportCaptureScreenState extends State<PassportCaptureScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Find back camera if possible
        final backCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras!.first,
        );

        _controller = CameraController(
          backCamera,
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to initialize camera.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capturePassport() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile file = await _controller!.takePicture();
      // We pass the captured file to the notifier and go to review screen
      widget.notifier.setImage(File(file.path));
      
      if (mounted) {
        context.push('/verification/passport-review');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture image. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _pickPassportFromGallery() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        widget.notifier.setImage(File(image.path));
        if (mounted) {
          context.push('/verification/passport-review');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _controller == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          CameraPreview(_controller!),

          // Overlay Mask
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(150),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ), // This one will be transparent
                ),
                Center(
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.85 * 1.4,
                    height: MediaQuery.sizeOf(context).width * 0.65, // Passport proportion ~ 1:1.4
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Passport Frame Border
          Center(
            child: Container(
              width: MediaQuery.sizeOf(context).width * 0.85 * 1.4,
              height: MediaQuery.sizeOf(context).width * 0.65,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // Top Bar
          Positioned(
            top: MediaQuery.paddingOf(context).top + 16,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/verification/status');
                }
              },
            ),
          ),

          // Instructions
          Positioned(
            top: MediaQuery.paddingOf(context).top + 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Icon(Icons.document_scanner, color: Colors.white, size: 32),
                const SizedBox(height: 16),
                Text(
                  'Position your passport\nwithin the frame',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Make sure all text is clear and readable',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Controls
          Positioned(
            bottom: 48,
            left: 32,
            right: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48), // Empty space on left to keep center button centered
                GestureDetector(
                  onTap: _capturePassport,
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Center(
                      child: Container(
                        height: 64,
                        width: 64,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: _isCapturing
                            ? const CircularProgressIndicator(color: Colors.black)
                            : null,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  iconSize: 32,
                  onPressed: _pickPassportFromGallery,
                  icon: const Icon(Icons.photo_library, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
