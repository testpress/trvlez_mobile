import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared scaffold for passport and video review screens.
///
/// Provides a light-themed, card-based layout consistent with the rest
/// of the KYC flow (stepper, central card, footer). Displays a media
/// preview, optional error message, and retake/upload action buttons.
///
/// Processing state is handled by [VerificationProcessingScreen] — this
/// scaffold is purely for reviewing captured media before upload.
class SharedReviewScaffold extends StatelessWidget {
  /// AppBar and card title.
  final String title;

  /// Instructional subtitle below the title.
  final String subtitle;

  /// The KYC stepper progress index (0 = Passport, 2 = Selfie).
  final int kycStepIndex;

  /// The media preview widget (image or video player).
  final Widget mediaChild;

  /// Optional error message to display above actions.
  final String? errorMessage;

  /// Called when the user taps "Retake".
  final VoidCallback onRetake;

  /// Called when the user taps "Upload".
  final VoidCallback onUpload;

  /// Text for the upload button (defaults to 'Upload').
  final String uploadText;

  /// Optional leading widget for the KYC stepper area.
  final Widget? stepper;

  const SharedReviewScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.kycStepIndex,
    required this.mediaChild,
    required this.onRetake,
    required this.onUpload,
    this.errorMessage,
    this.uploadText = 'Upload',
    this.stepper,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(colorScheme),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (stepper != null) ...[stepper!, const SizedBox(height: 24)],
              _buildContentCard(colorScheme),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colorScheme) {
    return AppBar(
      title: Text(
        'KYC',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: colorScheme.onSurface,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 18,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }

  Widget _buildContentCard(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.65),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Media preview
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 0.8,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: mediaChild,
            ),
          ),

          // Error message
          if (errorMessage != null) ...[
            const SizedBox(height: 16),
            _buildErrorBanner(colorScheme),
          ],
          const SizedBox(height: 24),

          // Action buttons
          _buildActionButtons(colorScheme),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorMessage!,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onRetake,
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.onSurface,
              side: BorderSide(color: colorScheme.outline),
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: Text(
              'Retake',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onUpload,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              elevation: 0,
            ),
            child: Text(
              uploadText,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
