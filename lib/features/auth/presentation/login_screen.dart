import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/network/api_exception.dart';
import 'package:trvlez_mobile/features/auth/presentation/login_controller.dart';

/// Traveler login screen.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends ConsumerState<LoginScreen>
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

  void onSubmit() {
    if (!formKey.currentState!.validate()) return;

    ref
        .read(loginControllerProvider.notifier)
        .login(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
  }

  // ─── Validation ───────────────────────────────────────────────────

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    // Simple email regex matching common patterns
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

  // ─── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final colors = context.colors;

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
                      buildLogo(colorScheme),
                      const SizedBox(height: AppSpacing.lg),
                      buildFormCard(theme, colorScheme),
                      const SizedBox(height: AppSpacing.lg),
                      buildSignUpLink(theme, colorScheme),
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

  // ─── Logo Section ─────────────────────────────────────────────────

  Widget buildLogo(ColorScheme colorScheme) {
    final colors = context.colors;
    return Column(
      children: [
        // App icon — red rounded square with plane icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withAlpha(80),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/logo.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                colors.textOnAction,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Brand name
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colors.textOnAction,
            ),
            children: [
              const TextSpan(text: 'Trvl'),
              TextSpan(
                text: 'Ez',
                style: TextStyle(color: colorScheme.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Form Card ────────────────────────────────────────────────────

  Widget buildFormCard(ThemeData theme, ColorScheme colorScheme) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 320),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: theme.dividerColor.withAlpha(30)),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withAlpha(10),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildHeader(theme),
            const SizedBox(height: 16),
            buildErrorBanner(colorScheme),
            buildEmailField(),
            const SizedBox(height: 12),
            buildPasswordField(colorScheme),
            const SizedBox(height: 20),
            buildSubmitButton(colorScheme),
          ],
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────

  Widget buildHeader(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Welcome back',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Sign in to continue your journey',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(180),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ─── Error Banner ─────────────────────────────────────────────────

  Widget buildErrorBanner(ColorScheme colorScheme) {
    final error = ref.watch(loginControllerProvider).error;
    final String? errorMessageText;
    if (error is AppException) {
      errorMessageText = error.message;
    } else if (error is ApiException) {
      errorMessageText = error.message;
    } else {
      errorMessageText = error?.toString();
    }
    if (errorMessageText == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.error.withAlpha(15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.error.withAlpha(50)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  errorMessageText,
                  style: GoogleFonts.cabin(
                    fontSize: 14,
                    color: colorScheme.error,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    ref.read(loginControllerProvider.notifier).clearError(),
                child: Icon(
                  Icons.close_rounded,
                  color: colorScheme.error.withAlpha(150),
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Form Fields ──────────────────────────────────────────────────

  Widget buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        TextFormField(
          controller: emailController,
          validator: validateEmail,
          enabled: !ref.watch(loginControllerProvider).isLoading,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          style: GoogleFonts.cabin(fontSize: 14),
          decoration: const InputDecoration(
            hintText: 'Enter your email address',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget buildPasswordField(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Password', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        TextFormField(
          controller: passwordController,
          validator: validatePassword,
          enabled: !ref.watch(loginControllerProvider).isLoading,
          obscureText: !isPasswordVisible,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => onSubmit(),
          style: GoogleFonts.cabin(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Enter your password',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixIconConstraints: const BoxConstraints(
              minHeight: 40,
              minWidth: 40,
            ),
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
        ),
      ],
    );
  }

  // ─── Submit Button ────────────────────────────────────────────────

  Widget buildSubmitButton(ColorScheme colorScheme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: FilledButton(
        onPressed: ref.watch(loginControllerProvider).isLoading
            ? null
            : onSubmit,
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 44),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.primary.withAlpha(180),
          disabledForegroundColor: colorScheme.onPrimary.withAlpha(200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: ref.watch(loginControllerProvider).isLoading ? 0 : 2,
          shadowColor: colorScheme.primary.withAlpha(60),
        ),
        child: ref.watch(loginControllerProvider).isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onPrimary.withAlpha(200),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Signing in...',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
            : Text(
                'Sign In',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  // ─── Footer Link ──────────────────────────────────────────────────

  Widget buildSignUpLink(ThemeData theme, ColorScheme colorScheme) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account? ',
          style: GoogleFonts.cabin(
            fontSize: 15,
            color: colors.textOnAction.withAlpha(220),
          ),
        ),
        GestureDetector(
          onTap: () {
            context.go(AppRoutes.register);
          },
          child: Text(
            'Sign Up',
            style: GoogleFonts.cabin(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
