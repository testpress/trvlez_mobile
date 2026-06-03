import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import 'verification_notifier.dart';

class SelfieReviewScreen extends StatefulWidget {
  final VerificationNotifier notifier;

  const SelfieReviewScreen({super.key, required this.notifier});

  @override
  State<SelfieReviewScreen> createState() => _SelfieReviewScreenState();
}

class _SelfieReviewScreenState extends State<SelfieReviewScreen> {
  VideoPlayerController? videoController;
  bool isPlaying = false;
  bool _isUploadingLocally = false;

  @override
  void initState() {
    super.initState();
    final videoFile = widget.notifier.capturedVideo;
    if (videoFile != null) {
      initializeVideo(videoFile);
    }
  }

  Future<void> initializeVideo(File videoFile) async {
    videoController = VideoPlayerController.file(videoFile);
    await videoController!.initialize();
    await videoController!.setLooping(true);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    videoController?.dispose();
    super.dispose();
  }

  void togglePlay() {
    if (videoController == null) return;
    
    if (videoController!.value.isPlaying) {
      videoController!.pause();
      setState(() => isPlaying = false);
    } else {
      videoController!.play();
      setState(() => isPlaying = true);
    }
  }

  Future<void> handleUpload() async {
    if (_isUploadingLocally) return;
    setState(() => _isUploadingLocally = true);
    await widget.notifier.uploadSelfie();

    if (!mounted) return;
    setState(() => _isUploadingLocally = false);

    if (widget.notifier.status == VerificationStatus.success) {
      // Navigate to the main app or success screen
      // For now, we'll just go back to onboarding or home
      if (context.canPop()) {
        context.go('/onboarding');
      }
    } else if (widget.notifier.status == VerificationStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.notifier.errorMessage ?? 'Upload failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Review Video'),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: ListenableBuilder(
        listenable: widget.notifier,
        builder: (context, _) {
          final status = widget.notifier.status;
          final isUploading = status == VerificationStatus.uploading;

          return Stack(
            fit: StackFit.expand,
            children: [
              if (videoController != null && videoController!.value.isInitialized)
                Center(
                  child: AspectRatio(
                    aspectRatio: videoController!.value.aspectRatio,
                    child: GestureDetector(
                      onTap: togglePlay,
                      child: VideoPlayer(videoController!),
                    ),
                  ),
                )
              else
                const Center(child: CircularProgressIndicator()),

              if (videoController != null && !isPlaying && !isUploading)
                Center(
                  child: IconButton(
                    iconSize: 64,
                    icon: const Icon(Icons.play_circle_fill, color: Colors.white),
                    onPressed: togglePlay,
                  ),
                ),

              if (isUploading)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 16),
                        Text(
                          'Uploading... ${(widget.notifier.uploadProgress * 100).toInt()}%',
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),

              if (!isUploading)
                Positioned(
                  bottom: 32,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            widget.notifier.clearVideo();
                            if (context.canPop()) {
                              context.pop();
                            }
                          },
                          child: const Text('Retake'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: handleUpload,
                          child: const Text('Upload'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
