import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';

/// Enlarged MRZ zoom card displaying the traveler's actual code lines
/// (cropped image and/or extracted text) rather than static placeholder data.
class VerifyZoomPanel extends ConsumerWidget {
  const VerifyZoomPanel({super.key, this.mrzImage, this.mrzLines});

  final File? mrzImage;
  final List<String>? mrzLines;

  File? _findExistingMrzImage(File? capturedImage) {
    if (capturedImage == null) return null;
    final mrzPath = capturedImage.path.replaceAll(
      RegExp(r'\.[^.]+$'),
      '_mrz_cropped.jpg',
    );
    final file = File(mrzPath);
    return file.existsSync() ? file : null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final state = ref.watch(verificationNotifierProvider);
    final lines = mrzLines ?? state.mrzLines;
    final image =
        mrzImage ??
        state.mrzImage ??
        _findExistingMrzImage(state.capturedImage);

    return Container(
      padding: space.insetCardCompact,
      decoration: BoxDecoration(
        color: colors.brandCardBackground,
        borderRadius: shape.radiusControl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: space.stackFormField,
                height: space.stackFormField,
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
              SizedBox(width: space.stackTight),
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
          SizedBox(height: space.stackItem),
          if (image != null && image.existsSync()) ...[
            Center(
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(maxHeight: sizes.controlXl),
                padding: EdgeInsets.all(space.stackTight / 2),
                decoration: BoxDecoration(
                  color: colors.brandShotBackdrop,
                  borderRadius: shape.radiusControlSm,
                  border: Border.all(
                    color: colors.brandBorderSubtle.withValues(alpha: 0.5),
                    width: shape.borderDefault,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: shape.radiusSubtle,
                  child: Image.file(image, fit: BoxFit.contain),
                ),
              ),
            ),
            if (lines != null && lines.isNotEmpty) ...[
              SizedBox(height: space.inlineMicro),
              Container(
                width: double.infinity,
                padding: space.insetTag,
                decoration: BoxDecoration(
                  color: colors.brandShotBackdrop,
                  borderRadius: shape.radiusSubtle,
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
                padding: EdgeInsets.symmetric(
                  vertical: space.stackItem,
                  horizontal: space.inlineIconLabel,
                ),
                decoration: BoxDecoration(
                  color: colors.brandShotBackdrop,
                  borderRadius: shape.radiusControlSm,
                  border: Border.all(
                    color: colors.brandBorderSubtle.withValues(alpha: 0.5),
                    width: shape.borderDefault,
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
                height: sizes.controlMd,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.brandShotBackdrop,
                  borderRadius: shape.radiusControlSm,
                  border: Border.all(
                    color: colors.brandBorderSubtle.withValues(alpha: 0.35),
                    width: shape.borderDefault,
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
