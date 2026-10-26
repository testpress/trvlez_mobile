import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_alt_line.dart';
import 'package:trvlez_mobile/core/widgets/brand_screen.dart';
import 'package:trvlez_mobile/core/widgets/brand_security_note.dart';
import 'package:trvlez_mobile/core/widgets/brand_text_field.dart';

/// Password reset request screen, supporting both unauthenticated reset
/// and change password flows for logged-in travelers.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    this.email = '',
    this.isChangePassword,
  });

  final String email;
  final bool? isChangePassword;

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  late final TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.email);
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
      extra: {'email': emailController.text.trim(), 'isPasswordReset': true},
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final authState = ref.watch(authNotifierProvider).valueOrNull;
    final isAlreadyLoggedIn =
        widget.isChangePassword ?? (authState?.isAuthenticated ?? false);

    return BrandScreen(
      backgroundAsset: 'assets/art/bg_log_in.svg',
      onBack: () => context.pop(),
      isScrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              isAlreadyLoggedIn ? 'Change your password' : 'Reset your password',
              style: context.text.headlineLarge?.copyWith(
                color: colors.brandOnSurface,
                height: 1.25,
              ),
            ),
          ),
          SizedBox(height: space.stackItem),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              isAlreadyLoggedIn
                  ? "We'll email you a code to update your password"
                  : "We'll email you a code to get back in",
              style: context.text.bodyLarge?.copyWith(
                color: colors.brandSecondaryBody,
                height: 1.45,
              ),
            ),
          ),

          SizedBox(height: space.stackSection),

          BrandTextField(
            label: 'Email',
            placeholder: 'Enter your email address',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            onSubmitted: _onSendCode,
          ),

          const Spacer(),

          const BrandSecurityNote(text: 'Codes expire after 10 minutes.'),

          SizedBox(height: space.stackFormField),

          AppButton(
            label: 'Send code',
            variant: AppButtonVariant.brandWhite,
            enabled: isEmailValid,
            onPressed: isEmailValid ? _onSendCode : null,
          ),

          if (!isAlreadyLoggedIn) ...[
            SizedBox(height: space.stackFormField),
            BrandAltLine(
              linkText: 'Back to log in',
              onTap: () => context.go(AppRoutes.login),
            ),
          ],
        ],
      ),
    );
  }
}
