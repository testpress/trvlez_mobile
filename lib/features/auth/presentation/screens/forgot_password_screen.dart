import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_alt_line.dart';
import 'package:trvlez_mobile/core/widgets/brand_screen.dart';
import 'package:trvlez_mobile/core/widgets/brand_security_note.dart';
import 'package:trvlez_mobile/core/widgets/brand_text_field.dart';

/// Password reset request screen.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    emailController.removeListener(_onTextChanged);
    emailController.dispose();
    super.dispose();
  }

  bool get isEmailValid {
    final text = emailController.text.trim();
    return text.contains('@') && text.contains('.') && text.length > 5;
  }

  void _onSendCode() {
    if (!isEmailValid) return;
    context.push(
      AppRoutes.twoStepCode,
      extra: {
        'email': emailController.text.trim(),
        'isPasswordReset': true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BrandScreen(
      backgroundAsset: 'assets/art/bg_log_in.svg',
      onBack: () => context.pop(),
      isScrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Reset your password',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 20,
              fontWeight: TypeScale.semiBold,
              color: colors.brandOnSurface,
              height: 1.25,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            "We'll email you a code to get back in",
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              fontWeight: TypeScale.regular,
              color: colors.brandSecondaryBody,
              height: 1.45,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          BrandTextField(
            label: 'Email',
            placeholder: 'Enter your email address',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            onSubmitted: _onSendCode,
          ),

          const SizedBox(height: AppSpacing.xxl),

          const BrandSecurityNote(
            text: 'Codes expire after 10 minutes.',
          ),

          const SizedBox(height: AppSpacing.md),

          AppButton(
            label: 'Send code',
            variant: AppButtonVariant.brandWhite,
            enabled: isEmailValid,
            onPressed: isEmailValid ? _onSendCode : null,
          ),

          const SizedBox(height: AppSpacing.md),

          BrandAltLine(
            linkText: 'Back to log in',
            onTap: () => context.go(AppRoutes.login),
          ),
        ],
      ),
    );
  }
}
