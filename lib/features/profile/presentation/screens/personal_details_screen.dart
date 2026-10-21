import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/features/profile/presentation/widgets/settings_group.dart';
import 'package:trvlez_mobile/features/profile/presentation/widgets/user_detail_edit_sheet.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';

/// Screen displaying user-owned details (Display name, email) and passport identity.
///
/// Under product rules:
/// - Identity is shown as the legal name ONLY (read-only, sourced from passport).
/// - Date of birth, nationality, and document number are never displayed.
/// - Legal name cannot be typed; it can only be updated via the Re-verify workflow.
class PersonalDetailsScreen extends ConsumerWidget {
  const PersonalDetailsScreen({super.key});

  void _confirmReverify(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Re-verify your identity?'),
        content: const Text(
          'This will re-scan your passport and confirm your updated legal name with a selfie and NFC check.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(verificationNotifierProvider.notifier).reset();
              context.push(AppRoutes.passportInstructions);
            },
            child: const Text('Start re-scan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final space = context.space;

    final profileState = ref.watch(currentProfileProvider);
    final profile = profileState.valueOrNull;

    final verificationState = ref.watch(travelerVerificationStateProvider);
    final isVerified = verificationState.isVerified;

    final displayName = profile?.displayName?.trim();
    final email = profile?.email ?? '';

    // Verified legal name from passport
    final legalName = profile?.legalName?.trim() ??
        (displayName?.isNotEmpty == true ? displayName! : 'Verified Traveler');

    return Scaffold(
      backgroundColor: colors.page,
      appBar: AppBar(
        backgroundColor: colors.page,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.arrowLeft, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Account',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 16,
            fontWeight: TypeScale.semiBold,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: space.insetCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal details',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 24,
                  fontWeight: TypeScale.bold,
                  letterSpacing: -0.5,
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: space.stackSection),

              // ── 1. Your details ─────────────────────────────────────────
              const SettingsGroupHeading('Your details'),
              _YourDetailsCard(
                displayName: displayName ?? '',
                email: email,
                onEditDisplayName: () => UserDetailEditSheet.show(
                  context,
                  fieldTitle: 'Display name',
                  initialValue: displayName ?? '',
                ),
                onChangeEmail: () => UserDetailEditSheet.show(
                  context,
                  fieldTitle: 'Email',
                  initialValue: email,
                  isEmail: true,
                ),
              ),

              SizedBox(height: space.stackSection),

              // ── 2. Identity ─────────────────────────────────────────────
              const SettingsGroupHeading('Identity'),
              if (isVerified)
                _VerifiedIdentityCard(
                  legalName: legalName,
                  onReverify: () => _confirmReverify(context, ref),
                )
              else
                _UnverifiedIdentityCard(
                  onStartVerify: () =>
                      context.push(AppRoutes.verificationLanding),
                ),

              SizedBox(height: space.stackSection),
            ],
          ),
        ),
      ),
    );
  }
}

class _YourDetailsCard extends StatelessWidget {
  const _YourDetailsCard({
    required this.displayName,
    required this.email,
    required this.onEditDisplayName,
    required this.onChangeEmail,
  });

  final String displayName;
  final String email;
  final VoidCallback onEditDisplayName;
  final VoidCallback onChangeEmail;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shape = context.shape;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: shape.radiusSurface,
        border: Border.all(
          color: colors.borderSubtle,
          width: shape.borderDefault,
        ),
      ),
      child: Column(
        children: [
          _RowTile(
            label: 'Display name',
            value: displayName.isNotEmpty ? displayName : 'Add name',
            actionText: 'Edit',
            onAction: onEditDisplayName,
          ),
          Divider(
            height: 1,
            thickness: shape.borderDefault,
            color: colors.borderSubtle,
          ),
          _RowTile(
            label: 'Email',
            value: email.isNotEmpty ? email : 'Add email',
            actionText: 'Change',
            onAction: onChangeEmail,
          ),
        ],
      ),
    );
  }
}

class _VerifiedIdentityCard extends StatelessWidget {
  const _VerifiedIdentityCard({
    required this.legalName,
    required this.onReverify,
  });

  final String legalName;
  final VoidCallback onReverify;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: shape.radiusSurface,
            border: Border.all(
              color: colors.borderSubtle,
              width: shape.borderDefault,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: space.insetCard.horizontal / 2,
                  vertical: space.stackItem,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceSubtle,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(shape.radiusSurface.topLeft.x),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'FROM YOUR PASSPORT',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: TypeScale.bold,
                        letterSpacing: 0.6,
                        color: colors.textSecondary,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: space.inlineItem,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.feedbackSuccess.withAlpha(30),
                        borderRadius: shape.radiusPill,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.check,
                            size: 13,
                            color: colors.feedbackSuccess,
                          ),
                          SizedBox(width: space.stackText),
                          Text(
                            'Verified',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 11,
                              fontWeight: TypeScale.bold,
                              color: colors.feedbackSuccess,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: shape.borderDefault,
                color: colors.borderSubtle,
              ),

              // Legal name row
              Padding(
                padding: space.insetCard,
                child: Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        'Legal name',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        legalName,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14,
                          fontWeight: TypeScale.semiBold,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      AppIcons.check,
                      size: 16,
                      color: colors.feedbackSuccess,
                    ),
                  ],
                ),
              ),

              Divider(
                height: 1,
                thickness: shape.borderDefault,
                color: colors.borderSubtle,
              ),

              // Re-verify row
              Padding(
                padding: space.insetCard,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Changed your legal name?',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 13.5,
                              fontWeight: TypeScale.semiBold,
                              color: colors.textPrimary,
                            ),
                          ),
                          SizedBox(height: space.stackText),
                          Text(
                            'Married, deed poll, new passport — re-scan to update it.',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 12,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: space.inlineItem),
                    TextButton(
                      onPressed: onReverify,
                      child: Text(
                        'Re-verify',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 13,
                          fontWeight: TypeScale.bold,
                          color: colors.brandPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: space.stackItem),

        // Privacy note
        Container(
          padding: space.insetCard,
          decoration: BoxDecoration(
            color: colors.surfaceSubtle,
            borderRadius: shape.radiusSurface,
            border: Border.all(
              color: colors.borderSubtle,
              width: shape.borderDefault,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                AppIcons.alertCircle,
                size: 16,
                color: colors.textSecondary,
              ),
              SizedBox(width: space.inlineItem),
              Expanded(
                child: Text(
                  'Your name comes from your passport and can\'t be typed. Your date of birth was checked once to confirm you\'re 18+, and is kept private.',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    height: 1.5,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UnverifiedIdentityCard extends StatelessWidget {
  const _UnverifiedIdentityCard({required this.onStartVerify});

  final VoidCallback onStartVerify;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: shape.radiusSurface,
            border: Border.all(
              color: colors.borderSubtle,
              width: shape.borderDefault,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: space.insetCard.horizontal / 2,
                  vertical: space.stackItem,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceSubtle,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(shape.radiusSurface.topLeft.x),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'FROM YOUR PASSPORT',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: TypeScale.bold,
                        letterSpacing: 0.6,
                        color: colors.textSecondary,
                      ),
                    ),
                    Icon(
                      AppIcons.lock,
                      size: 14,
                      color: colors.textDisabled,
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: shape.borderDefault,
                color: colors.borderSubtle,
              ),

              // Locked legal name row
              Padding(
                padding: space.insetCard,
                child: Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        'Legal name',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Add with your passport',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 14,
                          fontWeight: TypeScale.medium,
                          color: colors.textDisabled,
                        ),
                      ),
                    ),
                    Icon(
                      AppIcons.lock,
                      size: 14,
                      color: colors.textDisabled,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: space.stackItem),

        // Locked Note with red-tinted accent
        Container(
          padding: space.insetCard,
          decoration: BoxDecoration(
            color: colors.brandPrimary.withAlpha(16),
            borderRadius: shape.radiusSurface,
            border: Border.all(
              color: colors.brandPrimary.withAlpha(50),
              width: shape.borderDefault,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                AppIcons.alertCircle,
                size: 16,
                color: colors.brandPrimary,
              ),
              SizedBox(width: space.inlineItem),
              Expanded(
                child: Text(
                  'Your legal name comes straight from your passport chip. You can\'t type it in — and you won\'t need to.',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 12,
                    height: 1.5,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: space.stackSection),

        // Primary action button
        AppButton(
          label: 'Verify with your passport',
          icon: const Icon(AppIcons.idBadge2),
          onPressed: onStartVerify,
        ),
      ],
    );
  }
}

class _RowTile extends StatelessWidget {
  const _RowTile({
    required this.label,
    required this.value,
    required this.actionText,
    required this.onAction,
  });

  final String label;
  final String value;
  final String actionText;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: space.insetCard.horizontal / 2,
        vertical: space.stackItem,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                color: colors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 14,
                fontWeight: TypeScale.semiBold,
                color: colors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: onAction,
            child: Text(
              actionText,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                fontWeight: TypeScale.semiBold,
                color: colors.brandPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
