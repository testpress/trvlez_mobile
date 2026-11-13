import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/features/profile/presentation/providers/security_providers.dart';
import 'package:trvlez_mobile/features/profile/presentation/widgets/passcode_setup_sheet.dart';
import 'package:trvlez_mobile/features/profile/presentation/widgets/settings_group.dart';

/// Screen managing authentication, device Keychain app lock, and 2-step verification.
class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final text = context.text;

    final isPasscodeEnabled =
        ref.watch(appPasscodeNotifierProvider).valueOrNull ?? false;
    final isTwoStepEnabled = ref.watch(twoStepVerificationNotifierProvider);

    return Scaffold(
      backgroundColor: colors.page,
      appBar: AppBar(
        backgroundColor: colors.page,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.arrowLeft, color: colors.textPrimary),
          tooltip: 'Back',
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
                'Security',
                style: text.displaySmall?.copyWith(
                  letterSpacing: -0.5,
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: space.stackSection),
              SettingsGroup(
                rows: [
                  SettingsRow(
                    icon: AppIcons.lock,
                    label: 'Password',
                    value: '••••••••',
                    trailing: TextButton(
                      onPressed: () => context.push(
                        AppRoutes.forgotPassword,
                        extra: {'isChangePassword': true},
                      ),
                      child: Text(
                        'Change',
                        style: text.labelLarge?.copyWith(
                          color: colors.brandPrimary,
                        ),
                      ),
                    ),
                    onTap: () => context.push(
                      AppRoutes.forgotPassword,
                      extra: {'isChangePassword': true},
                    ),
                  ),
                  SettingsRow(
                    icon: AppIcons.shieldLock,
                    label: 'App passcode',
                    value: isPasscodeEnabled ? 'On' : 'Off',
                    onTap: () => PasscodeSetupSheet.show(
                      context,
                      isCurrentlyEnabled: isPasscodeEnabled,
                    ),
                  ),
                  SettingsRow(
                    icon: AppIcons.shield,
                    label: 'Two-step verification',
                    trailing: Semantics(
                      label: 'Two-step verification',
                      child: Switch.adaptive(
                        value: isTwoStepEnabled,
                        activeTrackColor: colors.brandPrimary,
                        onChanged: (_) {
                          ref
                              .read(
                                twoStepVerificationNotifierProvider.notifier,
                              )
                              .toggle();
                        },
                      ),
                    ),
                    onTap: () {
                      ref
                          .read(twoStepVerificationNotifierProvider.notifier)
                          .toggle();
                    },
                  ),
                ],
              ),
              SizedBox(height: space.stackItem),
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
                      size: sizes.iconXs + 2,
                      color: colors.textSecondary,
                    ),
                    SizedBox(width: space.inlineItem),
                    Expanded(
                      child: Text(
                        'Password gets you into the account. The app passcode locks the app on this phone, and lives in the Keychain — never on a server.',
                        style: text.labelMedium?.copyWith(
                          color: colors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
