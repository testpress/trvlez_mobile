import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/network/api_exception.dart';
import 'package:trvlez_mobile/features/profile/presentation/providers/profile_providers.dart';
import 'package:trvlez_mobile/features/profile/presentation/widgets/personal_details_form.dart';
import 'package:trvlez_mobile/features/profile/presentation/widgets/profile_avatar_uploader.dart';
import 'package:trvlez_mobile/features/profile/presentation/widgets/profile_error_banner.dart';

/// Traveler profile setup screen for onboarding completion.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => ProfileSetupScreenState();
}

class ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final passportNumberController = TextEditingController();

  String? selectedNationality;
  String? selectedGender;
  DateTime? selectedDateOfBirth;
  DateTime? selectedPassportExpiry;

  late final AnimationController fadeController;
  late final Animation<double> fadeAnimation;

  bool _isInitialized = false;

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
    phoneController.dispose();
    passportNumberController.dispose();
    fadeController.dispose();
    super.dispose();
  }

  Future<void> onSubmit() async {
    if (!formKey.currentState!.validate()) return;

    final success = await ref
        .read(currentProfileProvider.notifier)
        .updateProfile(
          phone: phoneController.text.trim(),
          nationality: selectedNationality,
          gender: selectedGender,
          dateOfBirth: selectedDateOfBirth,
          passportNumber: passportNumberController.text.trim().isNotEmpty
              ? passportNumberController.text.trim()
              : null,
          passportExpiry: selectedPassportExpiry,
        );

    if (success && mounted) {
      try {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.verificationLanding);
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentProfileProvider, (previous, next) {
      if (!mounted) return;
      if (!_isInitialized && next.hasValue) {
        final profile = next.value;
        if (profile != null) {
          phoneController.text = profile.phone ?? '';
          selectedNationality = profile.nationality;
          passportNumberController.text = profile.passportNumber ?? '';
          selectedGender = profile.gender;
          selectedDateOfBirth = profile.dateOfBirth;
          selectedPassportExpiry = profile.passportExpiry;
          _isInitialized = true;
          setState(() {});
        }
      }
    });

    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final profileState = ref.watch(currentProfileProvider);
    final error = profileState.error;
    String? errorMessage;
    if (error is AppException) {
      errorMessage = error.message;
    } else if (error is ApiException) {
      errorMessage = error.message;
    } else if (error != null) {
      errorMessage = error.toString();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Setup'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: space.stackSection,
              vertical: space.stackFormField,
            ),
            child: FadeTransition(
              opacity: fadeAnimation,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 480),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: shape.radiusOverlay,
                  border: Border.all(
                    color: colors.borderSubtle,
                    width: shape.borderDefault,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.textPrimary.withAlpha(10),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                padding: space.insetDialog,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const ProfileAvatarUploader(),
                    SizedBox(height: space.stackSection),
                    ProfileErrorBanner(errorMessage: errorMessage),
                    PersonalDetailsForm(
                      formKey: formKey,
                      phoneController: phoneController,
                      passportNumberController: passportNumberController,
                      selectedNationality: selectedNationality,
                      onNationalityChanged: (n) =>
                          setState(() => selectedNationality = n),
                      selectedGender: selectedGender,
                      onGenderChanged: (g) =>
                          setState(() => selectedGender = g),
                      selectedDateOfBirth: selectedDateOfBirth,
                      onDateOfBirthChanged: (d) =>
                          setState(() => selectedDateOfBirth = d),
                      selectedPassportExpiry: selectedPassportExpiry,
                      onPassportExpiryChanged: (d) =>
                          setState(() => selectedPassportExpiry = d),
                      isLoading: profileState.isLoading,
                      onSubmit: onSubmit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
