import 'package:flutter/material.dart';

/// Camera shutter and gallery picker control column for passport capture.
class PassportCaptureControls extends StatelessWidget {
  final bool isCapturing;
  final VoidCallback onCapture;
  final VoidCallback onPickGallery;
  final EdgeInsets padding;

  const PassportCaptureControls({
    super.key,
    required this.isCapturing,
    required this.onCapture,
    required this.onPickGallery,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: padding.right + 16,
      top: 0,
      bottom: 0,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: isCapturing ? null : onCapture,
              child: Opacity(
                opacity: isCapturing ? 0.5 : 1.0,
                child: Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: Container(
                      height: 56,
                      width: 56,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            IconButton(
              iconSize: 28,
              onPressed: isCapturing ? null : onPickGallery,
              icon: Icon(
                Icons.photo_library,
                color: isCapturing ? Colors.white38 : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
