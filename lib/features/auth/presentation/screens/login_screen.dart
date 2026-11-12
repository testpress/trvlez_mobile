import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_alt_line.dart';
import 'package:trvlez_mobile/core/widgets/brand_screen.dart';
import 'package:trvlez_mobile/core/widgets/brand_security_note.dart';
import 'package:trvlez_mobile/core/widgets/brand_text_field.dart';
import 'package:trvlez_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:trvlez_mobile/features/auth/presentation/widgets/auth_error_banner.dart';

/// Traveler login screen adhering to the brand design system.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends ConsumerState<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailController.addListener(_onFieldChanged);
    passwordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    emailController.removeListener(_onFieldChanged);
    passwordController.removeListener(_onFieldChanged);
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool get hasCredentialsEntered =>
      emailController.text.trim().isNotEmpty &&
      passwordController.text.isNotEmpty;

  bool get isCredentialsValid {
    final email = emailController.text.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email) && passwordController.text.isNotEmpty;
  }

  void onSubmit() {
    final form = formKey.currentState;
    if (form == null || !form.validate()) return;

    ref
        .read(loginControllerProvider.notifier)
        .login(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  String? _resolveErrorMessage(Object? error) {
    if (error == null) return null;
    return AppException.userMessage(
      error,
      'Login failed. Please check your credentials and try again.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final loginState = ref.watch(loginControllerProvider);

    return BrandScreen(
      backgroundAsset: 'assets/art/bg_log_in.svg',
      isScrollable: true,
      body: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Error Banner ─────────────────────────────────────────────
            if (loginState.hasError)
              AuthErrorBanner(
                errorMessage: _resolveErrorMessage(loginState.error),
                onDismiss: () =>
                    ref.read(loginControllerProvider.notifier).clearError(),
              ),

            // ── Header Typography ────────────────────────────────────────
            Text(
              'Welcome back',
              style: context.text.headlineLarge?.copyWith(
                color: colors.brandOnSurface,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: space.stackText),
            Text(
              'Sign in to continue your journey',
              style: context.text.bodyLarge?.copyWith(
                color: colors.brandSecondaryBody,
                height: 1.45,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: space.stackSection),

            // ── Form Inputs ──────────────────────────────────────────────
            BrandTextField(
              label: 'Email',
              placeholder: 'Enter your email address',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: validateEmail,
            ),

            SizedBox(height: space.stackFormField),

            BrandTextField(
              label: 'Password',
              placeholder: 'Enter your password',
              controller: passwordController,
              obscurable: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: validatePassword,
              onSubmitted: onSubmit,
            ),

            SizedBox(height: space.stackItem),

            // ── Forgot Password Link ─────────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: Semantics(
                button: true,
                label: 'Forgot password?',
                child: InkWell(
                  onTap: () => context.push(AppRoutes.forgotPassword),
                  borderRadius: shape.radiusSubtle,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: space.inlineMicro,
                      vertical: space.stackTight,
                    ),
                    child: Container(
                      padding: EdgeInsets.only(bottom: shape.borderDefault),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: colors.brandUnderline,
                            width: shape.borderDefault,
                          ),
                        ),
                      ),
                      child: Text(
                        'Forgot password?',
                        style: context.text.labelLarge?.copyWith(
                          color: colors.brandOnSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // ── Security Note ────────────────────────────────────────────
            const BrandSecurityNote(
              text:
                  'Proprietary ID verification. Encrypted.\nNever shared with external AI.',
            ),

            SizedBox(height: space.stackFormField),

            // ── Submit Button ────────────────────────────────────────────
            AppButton(
              label: 'Log in',
              variant: AppButtonVariant.brandWhite,
              active: isCredentialsValid,
              isLoading: loginState.isLoading,
              onPressed: onSubmit,
            ),

            SizedBox(height: space.stackFormField),

            // ── Alternative Action Line ──────────────────────────────────
            BrandAltLine(
              prefix: 'New to TRVLez? ',
              linkText: 'Create account',
              onTap: () => context.go(AppRoutes.register),
            ),
          ],
        ),
      ),
    );
  }
}
