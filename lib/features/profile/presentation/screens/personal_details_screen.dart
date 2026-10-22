import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/core/network/api_exception.dart';
import 'package:trvlez_mobile/core/providers/shared_providers.dart'
    show verificationNotifierProvider;
import 'package:trvlez_mobile/features/profile/presentation/widgets/settings_group.dart';
import 'package:trvlez_mobile/features/profile/presentation/widgets/unverified_identity_card.dart';
import 'package:trvlez_mobile/features/profile/presentation/widgets/user_detail_edit_sheet.dart';
import 'package:trvlez_mobile/features/profile/presentation/widgets/verified_identity_card.dart';
import 'package:trvlez_mobile/features/profile/presentation/widgets/your_details_card.dart';

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
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(verificationNotifierProvider.notifier)
                    .startReverification();
                if (context.mounted) {
                  context.push(AppRoutes.passportInstructions);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ApiException.extractMessage(
                          e,
                          'Failed to start re-verification. Please try again.',
                        ),
                      ),
                    ),
                  );
                }
              }
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
    final text = context.text;

    final profileState = ref.watch(currentProfileProvider);
    final profile = profileState.valueOrNull;

    final verificationState = ref.watch(travelerVerificationStateProvider);
    final isVerified = verificationState.isVerified;

    final displayName = profile?.displayName?.trim();
    final email = profile?.email ?? '';

    // Verified legal name from passport
    final legalName =
        profile?.legalName?.trim() ??
        ((displayName != null && displayName.isNotEmpty)
            ? displayName
            : 'Verified Traveler');

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
          style: text.titleLarge?.copyWith(color: colors.textPrimary),
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
                style: text.displaySmall?.copyWith(
                  letterSpacing: -0.5,
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: space.stackSection),

              // ── 1. Your details ─────────────────────────────────────────
              const SettingsGroupHeading('Your details'),
              YourDetailsCard(
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
                VerifiedIdentityCard(
                  legalName: legalName,
                  onReverify: () => _confirmReverify(context, ref),
                )
              else
                UnverifiedIdentityCard(
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
