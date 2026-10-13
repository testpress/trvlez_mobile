import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
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
    final currentThemeMode = ref.watch(themeModeProvider);
    final verificationState = ref.watch(travelerVerificationStateProvider);
    final verified = verificationState.isVerified;

    final profileState = ref.watch(currentProfileProvider);
    final profile = profileState.valueOrNull;

    final authState = ref.watch(authNotifierProvider).valueOrNull;
    final isAuthenticated = authState?.isAuthenticated ?? false;

    final reservations = ref.watch(reservationListProvider).valueOrNull ?? [];
    final guestName = reservations.isNotEmpty
        ? reservations.first.guestName
        : null;
    final name = (guestName != null && guestName.trim().isNotEmpty)
        ? guestName.trim()
        : 'Traveler Profile';

    final initials = (guestName != null && guestName.trim().isNotEmpty)
        ? name
              .split(' ')
              .where((p) => p.isNotEmpty)
              .map((p) => p[0])
              .take(2)
              .join()
              .toUpperCase()
        : 'T';

    final subtitle = (profile?.phone != null && profile!.phone!.isNotEmpty)
        ? profile.phone!
        : (profile?.nationality != null && profile!.nationality!.isNotEmpty
              ? profile.nationality!
              : (isAuthenticated ? 'Signed in' : 'Guest'));

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
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (verified)
                    VerifiedCard(
                      detail: profile?.passportExpiry != null
                          ? 'Passport · valid to ${profile!.passportExpiry!.year}'
                          : 'Passport approved',
                      onTap: () => context.push(AppRoutes.verificationStatus),
                    )
                  else
                    VerifyPromptCard(
                      onStart: () =>
                          context.push(AppRoutes.verificationLanding),
                    ),

                  // ── Personal ───────────────────────────────────────────
                  const SettingsGroupHeading('Personal'),
                  SettingsGroup(
                    rows: [
                      SettingsRow(
                        icon: AppIcons.user,
                        label: 'Personal details',
                        onTap: () => context.push(AppRoutes.profileSetup),
                      ),
                      SettingsRow(
                        icon: AppIcons.mail,
                        label: 'Email & phone',
                        onTap: () => context.push(AppRoutes.profileSetup),
                      ),
                      SettingsRow(
                        icon: AppIcons.users,
                        label: 'Travellers',
                        onTap: () => _showFeatureNotice(context, 'Travellers'),
                      ),
                    ],
                  ),

                  // ── Your data ──────────────────────────────────────────
                  const SettingsGroupHeading('Your data'),
                  SettingsGroup(
                    rows: [
                      SettingsRow(
                        icon: AppIcons.id,
                        label: 'Identity & documents',
                        onTap: () => context.push(AppRoutes.verificationStatus),
                      ),
                      SettingsRow(
                        icon: AppIcons.download,
                        label: 'Download your data',
                        onTap: () =>
                            _showFeatureNotice(context, 'Download data'),
                      ),
                    ],
                  ),

                  // ── Sharing & permissions ──────────────────────────────
                  const SettingsGroupHeading('Sharing & permissions'),
                  SettingsGroup(
                    rows: [
                      SettingsRow(
                        icon: AppIcons.shieldLock,
                        label: 'Who has your details',
                        onTap: () =>
                            _showFeatureNotice(context, 'Who has your details'),
                      ),
                      SettingsRow(
                        icon: AppIcons.adjustments,
                        label: 'Privacy choices',
                        onTap: () =>
                            _showFeatureNotice(context, 'Privacy choices'),
                      ),
                    ],
                  ),

                  // ── Payments ───────────────────────────────────────────
                  const SettingsGroupHeading('Payments'),
                  SettingsGroup(
                    rows: [
                      SettingsRow(
                        icon: AppIcons.creditCard,
                        label: 'Payment methods',
                        onTap: () =>
                            _showFeatureNotice(context, 'Payment methods'),
                      ),
                      SettingsRow(
                        icon: AppIcons.receipt,
                        label: 'Receipts',
                        onTap: () => _showFeatureNotice(context, 'Receipts'),
                      ),
                      SettingsRow(
                        icon: AppIcons.coin,
                        label: 'Currency',
                        value: 'GBP',
                        onTap: () => _showFeatureNotice(context, 'Currency'),
                      ),
                    ],
                  ),

                  // ── Security ───────────────────────────────────────────
                  const SettingsGroupHeading('Security'),
                  SettingsGroup(
                    rows: [
                      SettingsRow(
                        icon: AppIcons.key,
                        label: 'Change password',
                        onTap: () => context.push(AppRoutes.forgotPassword),
                      ),
                      SettingsRow(
                        icon: AppIcons.shieldCheck,
                        label: 'Two-step verification',
                        onTap: () => _showFeatureNotice(
                          context,
                          'Two-step verification',
                        ),
                      ),
                      SettingsRow(
                        icon: AppIcons.deviceMobile,
                        label: 'Devices',
                        onTap: () => _showFeatureNotice(context, 'Devices'),
                      ),
                    ],
                  ),

                  // ── Preferences ────────────────────────────────────────
                  const SettingsGroupHeading('Preferences'),
                  SettingsGroup(
                    rows: [
                      SettingsRow(
                        icon: AppIcons.language,
                        label: 'Language',
                        value: 'English',
                        onTap: () => _showFeatureNotice(context, 'Language'),
                      ),
                      SettingsRow(
                        icon: AppIcons.bell,
                        label: 'Notifications',
                        onTap: () => _showFeatureNotice(
                          context,
                          'Notification settings',
                        ),
                      ),
                      SettingsRow(
                        icon: AppIcons.bulb,
                        label: 'Dark mode',
                        value: currentThemeMode == ThemeMode.dark
                            ? 'On'
                            : 'Off',
                        trailing: Switch.adaptive(
                          value: currentThemeMode == ThemeMode.dark,
                          activeTrackColor: colors.brandPrimary,
                          onChanged: (_) {
                            ref.read(themeModeProvider.notifier).toggleTheme();
                          },
                        ),
                        onTap: () {
                          ref.read(themeModeProvider.notifier).toggleTheme();
                        },
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
                  const SizedBox(height: AppSpacing.lg),
                  Semantics(
                    button: true,
                    child: InkWell(
                      onTap: () => _confirmSignOut(context, ref),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Sign out',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 13,
                            fontWeight: TypeScale.bold,
                            color: colors.brandPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'TRVLez 1.0.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
