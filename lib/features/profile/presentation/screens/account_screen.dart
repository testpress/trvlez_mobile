import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/core/providers/shared_providers.dart'
    show reservationListProvider;
import 'package:trvlez_mobile/features/profile/presentation/widgets/account_profile_header.dart';
import 'package:trvlez_mobile/features/profile/presentation/widgets/settings_group.dart';
import 'package:trvlez_mobile/features/profile/presentation/widgets/verified_card.dart';
import 'package:trvlez_mobile/features/profile/presentation/widgets/verify_prompt_card.dart';

/// The Account screen showing traveler identity status, settings categories, and account controls.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  void _showFeatureNotice(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title is coming soon'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          "You'll need your email and password to sign back in.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(authNotifierProvider.notifier).logout();
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final space = context.space;
    final verificationState = ref.watch(travelerVerificationStateProvider);
    final verified = verificationState.isVerified;

    final profileState = ref.watch(currentProfileProvider);
    final profile = profileState.valueOrNull;

    final authState = ref.watch(authNotifierProvider).valueOrNull;
    final isAuthenticated = authState?.isAuthenticated ?? false;

    final reservations = ref.watch(reservationListProvider).valueOrNull ?? [];
    final displayName = profile?.displayName?.trim();
    final guestName = reservations.isNotEmpty
        ? reservations.first.guestName
        : null;
    final name = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : ((guestName != null && guestName.trim().isNotEmpty)
              ? guestName.trim()
              : 'Traveler');

    final safeInitials = name
        .split(' ')
        .where((p) => p.isNotEmpty)
        .map((p) => p[0])
        .take(2)
        .join()
        .toUpperCase();
    final initials = safeInitials.isNotEmpty ? safeInitials : 'T';

    final email = profile?.email;
    final String subtitle;
    if (email != null && email.isNotEmpty) {
      subtitle = email;
    } else if (isAuthenticated) {
      subtitle = 'Signed in';
    } else {
      subtitle = 'Guest';
    }

    return Scaffold(
      backgroundColor: colors.page,
      body: Column(
        children: [
          // ── Pinned Header ──────────────────────────────────────────────
          AccountProfileHeader(
            name: name,
            initials: initials,
            subtitle: subtitle,
          ),

          // ── Scrollable Settings Body ───────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: space.insetCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Verification Hero Card: sits on top until identity is verified, then drops away
                  if (!verified) ...[
                    if (verificationState.isProcessing)
                      VerifiedCard(
                        title: 'Verification in review',
                        detail: 'Our system is reviewing your documents',
                        icon: AppIcons.clock,
                        onTap: () => context.push(AppRoutes.verificationStatus),
                      )
                    else if (verificationState.isFailed)
                      VerifiedCard(
                        title: 'Verification needs attention',
                        detail: 'Tap to view details and re-submit',
                        icon: AppIcons.alertTriangle,
                        onTap: () => context.push(AppRoutes.verificationStatus),
                      )
                    else
                      VerifyPromptCard(
                        onStart: () =>
                            context.push(AppRoutes.verificationLanding),
                      ),
                    SizedBox(height: space.stackItem),
                  ],

                  // ── Personal ───────────────────────────────────────────
                  const SettingsGroupHeading('Personal'),
                  SettingsGroup(
                    rows: [
                      SettingsRow(
                        icon: AppIcons.user,
                        label: 'Personal details',
                        onTap: () => context.push(AppRoutes.personalDetails),
                      ),
                      SettingsRow(
                        icon: AppIcons.mail,
                        label: 'Email & phone',
                        onTap: () => context.push(AppRoutes.personalDetails),
                      ),
                      SettingsRow(
                        icon: AppIcons.users,
                        label: 'Travellers',
                        value: 'None yet',
                        onTap: () => _showFeatureNotice(context, 'Travellers'),
                      ),
                    ],
                  ),

                  // ── Settings ───────────────────────────────────────────
                  const SettingsGroupHeading('Settings'),
                  SettingsGroup(
                    rows: [
                      SettingsRow(
                        icon: AppIcons.shieldLock,
                        label: 'Security',
                        value: 'Password, passcode',
                        onTap: () => context.push(AppRoutes.security),
                      ),
                      SettingsRow(
                        icon: AppIcons.adjustments,
                        label: 'Preferences',
                        value: 'Text size',
                        onTap: () => context.push(AppRoutes.preferences),
                      ),
                    ],
                  ),

                  // ── Support ────────────────────────────────────────────
                  const SettingsGroupHeading('Support'),
                  SettingsGroup(
                    rows: [
                      SettingsRow(
                        icon: AppIcons.help,
                        label: 'Help centre',
                        onTap: () => _showFeatureNotice(context, 'Help centre'),
                      ),
                      SettingsRow(
                        icon: AppIcons.messageCircle,
                        label: 'Contact us',
                        onTap: () => _showFeatureNotice(context, 'Contact us'),
                      ),
                      SettingsRow(
                        icon: AppIcons.users,
                        label: 'Invite a friend',
                        onTap: () =>
                            _showFeatureNotice(context, 'Invite a friend'),
                      ),
                      SettingsRow(
                        icon: AppIcons.fileText,
                        label: 'Terms & privacy',
                        onTap: () =>
                            _showFeatureNotice(context, 'Terms & privacy'),
                      ),
                      SettingsRow(
                        icon: AppIcons.trash,
                        label: 'Close my account',
                        danger: true,
                        onTap: () => context.push(AppRoutes.closeAccount),
                      ),
                    ],
                  ),

                  // ── Footer ─────────────────────────────────────────────
                  SizedBox(height: space.stackSection),
                  Semantics(
                    button: true,
                    child: InkWell(
                      onTap: () => _confirmSignOut(context, ref),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: space.stackItem,
                        ),
                        child: Text(
                          'Sign out',
                          textAlign: TextAlign.center,
                          style: context.text.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.brandPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: space.stackText),
                  Text(
                    'TRVLez 1.0.0',
                    textAlign: TextAlign.center,
                    style: context.text.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  SizedBox(height: space.stackSection),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
