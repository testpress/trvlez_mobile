import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/storage/passcode_storage.dart';
import 'package:trvlez_mobile/core/storage/settings_repository.dart';
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
                'Security',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 24,
                  fontWeight: TypeScale.bold,
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
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          color: colors.brandPrimary,
                          fontWeight: TypeScale.semiBold,
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
                    trailing: Switch.adaptive(
                      value: isTwoStepEnabled,
                      activeTrackColor: colors.brandPrimary,
                      onChanged: (_) {
                        ref
                            .read(twoStepVerificationNotifierProvider.notifier)
                            .toggle();
                      },
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
                      size: 16,
                      color: colors.textSecondary,
                    ),
                    SizedBox(width: space.inlineItem),
                    Expanded(
                      child: Text(
                        'Password gets you into the account. The app passcode locks the app on this phone, and lives in the Keychain — never on a server.',
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
          ),
        ),
      ),
    );
  }
}
