import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/network/api_exception.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_alt_line.dart';
import 'package:trvlez_mobile/core/widgets/brand_screen.dart';
import 'package:trvlez_mobile/core/widgets/brand_security_note.dart';
import 'package:trvlez_mobile/core/widgets/brand_text_field.dart';
import 'package:trvlez_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:trvlez_mobile/features/auth/presentation/widgets/auth_error_banner.dart';

/// Traveler account creation screen adhering to the brand design system.
class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => RegistrationScreenState();
}

class RegistrationScreenState extends ConsumerState<RegistrationScreen> {
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

  bool get credentialsEntered =>
      emailController.text.trim().isNotEmpty &&
      passwordController.text.length >= 8;

  void showSuccessAndNavigate() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Account created successfully!',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontWeight: TypeScale.medium,
          ),
        ),
        backgroundColor: context.colors.feedbackSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: context.shape.radiusControl,
        ),
        margin: EdgeInsets.all(context.space.stackFormField),
      ),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      try {
        context.go(AppRoutes.login);
      } catch (_) {
        // Fallback for standalone tests
      }
    });
  }

  void onSubmit() {
    if (!formKey.currentState!.validate()) return;

    ref
        .read(registrationControllerProvider.notifier)
        .signUp(
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
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (value.length > 128) {
      return 'Password must be 128 characters or fewer';
    }
    return null;
  }

  String? _resolveErrorMessage(Object? error) {
    if (error is AppException) return error.message;
    if (error is ApiException) return error.message;
    return error?.toString();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(registrationControllerProvider, (
      previous,
      next,
    ) {
      if (!next.isLoading && !next.hasError && previous?.isLoading == true) {
        showSuccessAndNavigate();
      }
    });

    final colors = context.colors;
    final space = context.space;
    final regState = ref.watch(registrationControllerProvider);

    return BrandScreen(
      backgroundAsset: 'assets/art/bg_create_account.svg',
      isScrollable: true,
      body: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Error Banner ─────────────────────────────────────────────
            if (regState.hasError)
              AuthErrorBanner(
                errorMessage: _resolveErrorMessage(regState.error),
                onDismiss: () => ref
                    .read(registrationControllerProvider.notifier)
                    .clearError(),
              ),

            // ── Header Typography ────────────────────────────────────────
            Text(
              'Create your account',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 20,
                fontWeight: TypeScale.semiBold,
                color: colors.brandOnSurface,
                height: 1.25,
              ),
            ),
            SizedBox(height: space.stackText),
            Text(
              'Start your seamless travel journey',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                fontWeight: TypeScale.regular,
                color: colors.brandSecondaryBody,
                height: 1.45,
              ),
            ),

            SizedBox(height: space.stackSection),

            // ── Form Inputs ──────────────────────────────────────────────
            BrandTextField(
              label: 'Email',
              placeholder: 'you@example.com',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: validateEmail,
            ),

            SizedBox(height: space.stackFormField),

            BrandTextField(
              label: 'Password',
              placeholder: 'At least 8 characters',
              controller: passwordController,
              obscurable: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              validator: validatePassword,
              onSubmitted: onSubmit,
            ),

            SizedBox(height: space.stackHero),

            // ── Security Note ────────────────────────────────────────────
            const BrandSecurityNote(
              text:
                  'Proprietary ID verification. Encrypted.\nNever shared with external AI.',
            ),

            SizedBox(height: space.stackFormField),

            // ── Submit Button ────────────────────────────────────────────
            AppButton(
              label: 'Create account',
              variant: AppButtonVariant.brandWhite,
              isLoading: regState.isLoading,
              onPressed: onSubmit,
            ),

            SizedBox(height: space.stackFormField),

            // ── Alternative Action Line ──────────────────────────────────
            BrandAltLine(
              prefix: 'Already have an account? ',
              linkText: 'Log in',
              onTap: () => context.go(AppRoutes.login),
            ),
          ],
        ),
      ),
    );
  }
}
