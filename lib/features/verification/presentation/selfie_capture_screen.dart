import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';


import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/core/device/camera_service.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/face_guide_painter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_providers.dart';
import 'package:trvlez_mobile/app/routes.dart';
class SelfieCaptureScreen extends ConsumerStatefulWidget {
  final CameraService cameraService;

  const SelfieCaptureScreen({
    super.key, 
    required this.cameraService,
  });

  @override
  ConsumerState<SelfieCaptureScreen> createState() => SelfieCaptureScreenState();
}

class SelfieCaptureScreenState extends ConsumerState<SelfieCaptureScreen>
    with TickerProviderStateMixin {
  CameraController? cameraController;
  bool isInitializing = true;
  bool isRecording = false;
  String? errorMsg;
  int recordedSeconds = 0;
  Timer? recordingTimer;
  late AnimationController progressController;

  static const int minRecordingSeconds = 3;
  static const int maxRecordingSeconds = 10;

  @override
  void initState() {
    super.initState();
    progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: maxRecordingSeconds),
    );
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      cameraController = await widget.cameraService.initCamera(
        lensDirection: CameraLensDirection.front,
        resolution: ResolutionPreset.high,
        enableAudio: false,
      );

      if (cameraController == null) {
        if (mounted) {
          setState(() {
            errorMsg = 'No cameras available';
            isInitializing = false;
          });
        }
        return;
      }

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
      progressController.forward(from: 0.0);

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
    progressController.stop();

    try {
      final video = await cameraController!.stopVideoRecording();

      setState(() {
        isRecording = false;
      });

      if (recordedSeconds >= minRecordingSeconds) {
        ref.read(verificationNotifierProvider.notifier).setVideo(File(video.path));
        if (mounted) {
          context.push(AppRoutes.selfieReview);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video must be at least 3 seconds long'),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        isRecording = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to stop recording: $e')));
      }
    }
  }

  Future<void> pickVideoFromGallery() async {
    if (isRecording) return;

    try {
      final File? video = await widget.cameraService.pickVideoFromGallery();

      if (video != null) {
        ref.read(verificationNotifierProvider.notifier).setVideo(video);
        if (mounted) {
          context.push(AppRoutes.selfieReview);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick video. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    recordingTimer?.cancel();
    progressController.dispose();
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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

          // Face Guide Overlay
          Positioned.fill(
            child: AnimatedBuilder(
              animation: progressController,
              builder: (context, child) {
                return CustomPaint(
                  painter: FaceGuidePainter(progress: progressController.value),
                );
              },
            ),
          ),

          _buildInstructionsOverlay(),
          if (isRecording) _buildTimerOverlay(),
          _buildControls(isMinTimeMet),
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildInstructionsOverlay() {
    return const Positioned(
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
    );
  }

  Widget _buildTimerOverlay() {
    return Positioned(
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
    );
  }

  Widget _buildControls(bool isMinTimeMet) {
    return Positioned(
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
              onPressed: pickVideoFromGallery,
              icon: const Icon(Icons.video_library, color: Colors.white),
            )
          else
            const SizedBox(width: 48), // Match the size of the gallery button when hidden
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
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
          } else {
            context.go(AppRoutes.verificationStatus);
          }
        },
      ),
    );
  }
}
