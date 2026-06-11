import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'verification_notifier.dart';

class SelfieCaptureScreen extends StatefulWidget {
  final VerificationNotifier notifier;

  const SelfieCaptureScreen({super.key, required this.notifier});

  @override
  State<SelfieCaptureScreen> createState() => _SelfieCaptureScreenState();
}

class _SelfieCaptureScreenState extends State<SelfieCaptureScreen> {
  CameraController? cameraController;
  List<CameraDescription> cameras = [];
  bool isInitializing = true;
  bool isRecording = false;
  String? errorMsg;
  int recordedSeconds = 0;
  Timer? recordingTimer;

  static const int minRecordingSeconds = 3;
  static const int maxRecordingSeconds = 10;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          errorMsg = 'No cameras available';
          isInitializing = false;
        });
        return;
      }

      // Try to find the front camera, fallback to first available
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false, // For selfie verification, audio might not be needed
      );

      await cameraController?.initialize();
      
      if (mounted) {
        setState(() {
          isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMsg = 'Failed to initialize camera: $e';
          isInitializing = false;
        });
      }
    }
  }

  Future<void> startRecording() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    if (cameraController!.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController!.startVideoRecording();
      setState(() {
        isRecording = true;
        recordedSeconds = 0;
      });

      recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        
        setState(() {
          recordedSeconds++;
        });

        if (recordedSeconds >= maxRecordingSeconds) {
          stopRecording();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start recording: $e')),
        );
      }
    }
  }

  Future<void> stopRecording() async {
    if (cameraController == null || !cameraController!.value.isRecordingVideo) {
      return;
    }

    recordingTimer?.cancel();
    
    try {
      final video = await cameraController!.stopVideoRecording();
      
      setState(() {
        isRecording = false;
      });

      if (recordedSeconds >= minRecordingSeconds) {
        widget.notifier.setVideo(File(video.path));
        if (mounted) {
          context.push('/verification/selfie-review');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video must be at least 3 seconds long')),
          );
        }
      }
    } catch (e) {
      setState(() {
        isRecording = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to stop recording: $e')),
        );
      }
    }
  }

  Future<void> _pickVideoFromGallery() async {
    if (isRecording) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
      
      if (video != null) {
        widget.notifier.setVideo(File(video.path));
        if (mounted) {
          context.push('/verification/selfie-review');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick video. Please try again.')),
        );
      }
    }
  }

  @override
  void dispose() {
    recordingTimer?.cancel();
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isInitializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMsg != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMsg!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isInitializing = true;
                    errorMsg = null;
                  });
                  initializeCamera();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final isMinTimeMet = recordedSeconds >= minRecordingSeconds;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (cameraController != null && cameraController!.value.isInitialized)
            CameraPreview(cameraController!),
          
          // Instructions Overlay
          const Positioned(
            top: 64,
            left: 24,
            right: 24,
            child: Text(
              'Please look directly into the camera',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
              ),
            ),
          ),

          // Timer Overlay
          if (isRecording)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '00:${recordedSeconds.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
                const SizedBox(width: 48), // Spacer to keep record button centered
                if (!isRecording)
                  FloatingActionButton(
                    heroTag: 'record_btn',
                    onPressed: startRecording,
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.videocam, color: Colors.white),
                  )
                else
                  FloatingActionButton(
                    heroTag: 'stop_btn',
                    onPressed: stopRecording,
                    backgroundColor: isMinTimeMet ? Colors.red : Colors.grey,
                    child: const Icon(Icons.stop, color: Colors.white),
                  ),
                if (!isRecording)
                  IconButton(
                    iconSize: 32,
                    onPressed: _pickVideoFromGallery,
                    icon: const Icon(Icons.video_library, color: Colors.white),
                  )
                else
                  const SizedBox(width: 48), // Match the size of the gallery button when hidden
              ],
            ),
          ),

          // Back Button
          Positioned(
            top: 48,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                if (isRecording) {
                  stopRecording();
                }
                if (context.canPop()) {
                  context.pop();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
