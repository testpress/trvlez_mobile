import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/network/api_exception.dart';
import 'package:trvlez_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:trvlez_mobile/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:trvlez_mobile/features/auth/presentation/widgets/auth_logo_header.dart';
import 'package:trvlez_mobile/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:trvlez_mobile/features/auth/presentation/widgets/auth_text_input.dart';

/// Traveler registration screen.
class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => RegistrationScreenState();
}

class RegistrationScreenState extends ConsumerState<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late final AnimationController fadeController;
  late final Animation<double> fadeAnimation;

  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    fadeAnimation = CurvedAnimation(
      parent: fadeController,
      curve: Curves.easeOut,
    );
    fadeController.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    fadeController.dispose();
    super.dispose();
  }

  void showSuccessAndNavigate() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Account created successfully!',
          style: GoogleFonts.cabin(fontWeight: FontWeight.w500),
        ),
        backgroundColor: context.colors.feedbackSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      try {
        context.go(AppRoutes.login);
      } catch (_) {
        // Fallback for standalone widget tests
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

  // ─── Validation ───────────────────────────────────────────────────

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

  // ─── Build ────────────────────────────────────────────────────────

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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final colors = context.colors;
    final registrationState = ref.watch(registrationControllerProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/frame.png', fit: BoxFit.cover),
          Container(color: colors.textPrimary.withAlpha(90)),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xl,
                ),
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AuthLogoHeader(),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 320),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: AppRadius.card,
                          border: Border.all(
                            color: theme.dividerColor.withAlpha(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.textPrimary.withAlpha(10),
                              blurRadius: 40,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 24,
                        ),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Create your account',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Join TrvlEz to explore & verify seamlessly',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withAlpha(180),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              AuthErrorBanner(
                                errorMessage: _resolveErrorMessage(
                                  registrationState.error,
                                ),
                                onDismiss: () => ref
                                    .read(
                                      registrationControllerProvider.notifier,
                                    )
                                    .clearError(),
                              ),
                              AuthTextInput(
                                label: 'Email',
                                controller: emailController,
                                hintText: 'Enter your email address',
                                validator: validateEmail,
                                enabled: !registrationState.isLoading,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 12),
                              AuthTextInput(
                                label: 'Password',
                                controller: passwordController,
                                hintText: 'Create a password (min 8 chars)',
                                validator: validatePassword,
                                enabled: !registrationState.isLoading,
                                obscureText: !isPasswordVisible,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => onSubmit(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isPasswordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: colorScheme.onSurface.withAlpha(120),
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisible = !isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                              AuthSubmitButton(
                                isLoading: registrationState.isLoading,
                                onPressed: onSubmit,
                                label: 'Create Account',
                                loadingLabel: 'Creating account...',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: GoogleFonts.cabin(
                              fontSize: 15,
                              color: colors.textOnAction.withAlpha(220),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go(AppRoutes.login),
                            child: Text(
                              'Sign In',
                              style: GoogleFonts.cabin(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
