import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/features/profile/presentation/widgets/settings_group.dart';
import 'package:trvlez_mobile/features/profile/presentation/widgets/text_size_selector.dart';

/// Screen managing reading size and appearance preferences.
class PreferencesScreen extends ConsumerWidget {
  const PreferencesScreen({super.key});

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final currentMode = ref.read(themeModeProvider);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Choose Theme'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
              Navigator.pop(dialogContext);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    currentMode == ThemeMode.system
                        ? AppIcons.circleCheck
                        : AppIcons.check,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  const Text('System default'),
                ],
              ),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
              Navigator.pop(dialogContext);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    currentMode == ThemeMode.light
                        ? AppIcons.circleCheck
                        : AppIcons.check,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  const Text('Light'),
                ],
              ),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
              Navigator.pop(dialogContext);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    currentMode == ThemeMode.dark
                        ? AppIcons.circleCheck
                        : AppIcons.check,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  const Text('Dark'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final space = context.space;
    final currentThemeMode = ref.watch(themeModeProvider);

    final themeLabel = switch (currentThemeMode) {
      ThemeMode.system => 'System',
      ThemeMode.dark => 'Dark',
      ThemeMode.light => 'Light',
    };

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
                'Preferences',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 24,
                  fontWeight: TypeScale.bold,
                  letterSpacing: -0.5,
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: space.stackSection),
              const SettingsGroupHeading('Reading'),
              const TextSizeSelector(),
              SizedBox(height: space.stackSection),
              const SettingsGroupHeading('Appearance'),
              SettingsGroup(
                rows: [
                  SettingsRow(
                    icon: AppIcons.bulb,
                    label: 'Theme',
                    value: themeLabel,
                    onTap: () => _showThemeDialog(context, ref),
                  ),
                ],
              ),
              SizedBox(height: space.stackSection),
            ],
          ),
        ),
      ),
    );
  }
}
