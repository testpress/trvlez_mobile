import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';

/// Avatar presentation and image uploader placeholder for traveler profile setup.
class ProfileAvatarUploader extends StatelessWidget {
  const ProfileAvatarUploader({this.avatarUrl, this.onUploadTap, super.key});

  final String? avatarUrl;
  final VoidCallback? onUploadTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final theme = Theme.of(context);

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: sizes.avatarXl,
              height: sizes.avatarXl,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surfaceSubtle,
                border: Border.all(
                  color: colors.borderDefault,
                  width: shape.borderFocus,
                ),
              ),
              child: ClipOval(
                child: (avatarUrl != null && avatarUrl!.isNotEmpty)
                    ? Image.network(
                        avatarUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: SizedBox.square(
                              dimension: sizes.iconDefault,
                              child: CircularProgressIndicator(
                                strokeWidth: shape.borderFocus,
                                color: colors.brandPrimary,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person_rounded,
                          size: sizes.iconHero,
                          color: colors.textSecondary,
                        ),
                      )
                    : Icon(
                        Icons.person_rounded,
                        size: sizes.iconHero,
                        color: colors.textSecondary,
                      ),
              ),
            ),
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onUploadTap,
                child: Container(
                  padding: EdgeInsets.all(space.stackTight),
                  decoration: BoxDecoration(
                    color: colors.actionPrimary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.surface,
                      width: shape.borderFocus,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.textPrimary.withAlpha(20),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: sizes.iconSm,
                    color: colors.textOnAction,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: space.stackFormField),
        Text(
          'Complete Your Profile',
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: space.stackItem),
        Text(
          'We need a bit more info to verify your account',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
