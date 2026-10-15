import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';

/// Enlarged MRZ zoom card displaying the traveler's actual code lines
/// (cropped image and/or extracted text) rather than static placeholder data.
class VerifyZoomPanel extends ConsumerWidget {
  const VerifyZoomPanel({
    super.key,
    this.mrzImage,
    this.mrzLines,
  });

  final File? mrzImage;
  final List<String>? mrzLines;

  File? _findExistingMrzImage(File? capturedImage) {
    if (capturedImage == null) return null;
    final mrzPath =
        capturedImage.path.replaceAll(RegExp(r'\.[^.]+$'), '_mrz_cropped.jpg');
    final file = File(mrzPath);
    return file.existsSync() ? file : null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final state = ref.watch(verificationNotifierProvider);
    final lines = mrzLines ?? state.mrzLines;
    final image = mrzImage ??
        state.mrzImage ??
        _findExistingMrzImage(state.capturedImage);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: colors.brandCardBackground,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 16.0,
                height: 16.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.brandSecondary,
                ),
                child: Text(
                  '2',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10.0,
                    fontWeight: TypeScale.bold,
                    color: colors.brandActionLabel,
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: 6.0),
              Text(
                'Code lines, enlarged',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11.5,
                  fontWeight: TypeScale.semiBold,
                  color: colors.brandOnSurface,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  'Can you read every character?',
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 10.0,
                    fontWeight: TypeScale.regular,
                    color: colors.brandSecondaryBody,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (image != null && image.existsSync()) ...[
            Center(
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 54.0),
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  color: colors.brandShotBackdrop,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: colors.brandBorderSubtle.withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  child: Image.file(
                    image,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            if (lines != null && lines.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: colors.brandShotBackdrop,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: lines
                      .map(
                        (line) => Text(
                          line,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10.5,
                            fontWeight: TypeScale.bold,
                            letterSpacing: 1.0,
                            color: colors.brandOnSurface,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ] else if (lines != null && lines.isNotEmpty) ...[
            Center(
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                decoration: BoxDecoration(
                  color: colors.brandShotBackdrop,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: colors.brandBorderSubtle.withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: lines
                      .map(
                        (line) => Text(
                          line,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11.0,
                            fontWeight: TypeScale.bold,
                            letterSpacing: 1.1,
                            color: colors.brandOnSurface,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ] else ...[
            Center(
              child: Container(
                width: double.infinity,
                height: 44.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.brandShotBackdrop,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: colors.brandBorderSubtle.withValues(alpha: 0.35),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  'Passport code lines preview will appear here',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 11.0,
                    fontWeight: TypeScale.regular,
                    color: colors.brandSecondaryBody,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
