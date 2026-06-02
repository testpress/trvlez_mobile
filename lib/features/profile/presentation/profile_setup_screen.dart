import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'profile_notifier.dart';

class ProfileSetupScreen extends StatefulWidget {
  final ProfileNotifier profileNotifier;

  const ProfileSetupScreen({
    super.key,
    required this.profileNotifier,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final nationalityController = TextEditingController();
  String? selectedGender;
  DateTime? selectedDateOfBirth;

  late final AnimationController fadeController;
  late final Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();
    widget.profileNotifier.addListener(onNotifierChanged);

    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    fadeAnimation = CurvedAnimation(
      parent: fadeController,
      curve: Curves.easeOut,
    );
    fadeController.forward();

    // Load existing profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.profileNotifier.loadProfile().then((_) {
        final profile = widget.profileNotifier.profile;
        if (profile != null && mounted) {
          setState(() {
            phoneController.text = profile.phone ?? '';
            nationalityController.text = profile.nationality ?? '';
            selectedGender = profile.gender;
            selectedDateOfBirth = profile.dateOfBirth;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    widget.profileNotifier.removeListener(onNotifierChanged);
    phoneController.dispose();
    nationalityController.dispose();
    fadeController.dispose();
    super.dispose();
  }

  void onNotifierChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDateOfBirth) {
      setState(() {
        selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> onSubmit() async {
    if (!formKey.currentState!.validate()) return;

    final success = await widget.profileNotifier.updateProfile(
      phone: phoneController.text.trim(),
      nationality: nationalityController.text.trim(),
      gender: selectedGender,
      dateOfBirth: selectedDateOfBirth,
    );

    if (success && mounted) {
      // Proceed back to the onboarding journey
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/onboarding');
      }
    }
  }

  // ─── Validation ───────────────────────────────────────────────────

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // ─── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Setup'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: FadeTransition(
              opacity: fadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildFormCard(theme, colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Form Card ────────────────────────────────────────────────────

  Widget buildFormCard(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 480),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withAlpha(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildHeader(theme),
            const SizedBox(height: 28),
            buildErrorBanner(colorScheme),
            buildTextField(
              controller: phoneController,
              label: 'Phone Number',
              hint: 'Enter your phone number',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            buildTextField(
              controller: nationalityController,
              label: 'Nationality',
              hint: 'Enter your nationality',
            ),
            const SizedBox(height: 16),
            buildGenderDropdown(colorScheme),
            const SizedBox(height: 16),
            buildDatePicker(colorScheme),
            const SizedBox(height: 32),
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
          'Complete Your Profile',
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'We need a bit more info to verify your account',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(180),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ─── Error Banner ─────────────────────────────────────────────────

  Widget buildErrorBanner(ColorScheme colorScheme) {
    final errorMessageText = widget.profileNotifier.errorMessage;
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
            ],
          ),
        ),
      ),
    );
  }

  // ─── Form Fields ──────────────────────────────────────────────────

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: (val) => validateRequired(val, label),
          enabled: !widget.profileNotifier.isLoading,
          keyboardType: keyboardType,
          textInputAction: TextInputAction.next,
          style: GoogleFonts.cabin(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
          ),
        ),
      ],
    );
  }

  Widget buildGenderDropdown(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedGender,
          decoration: const InputDecoration(
            hintText: 'Select your gender',
          ),
          items: const [
            DropdownMenuItem(value: 'male', child: Text('Male')),
            DropdownMenuItem(value: 'female', child: Text('Female')),
            DropdownMenuItem(value: 'other', child: Text('Other')),
            DropdownMenuItem(value: 'prefer_not_to_say', child: Text('Prefer not to say')),
          ],
          onChanged: widget.profileNotifier.isLoading
              ? null
              : (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
        ),
      ],
    );
  }

  Widget buildDatePicker(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: widget.profileNotifier.isLoading ? null : () => _selectDate(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.onSurface.withAlpha(50),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDateOfBirth == null
                      ? 'Select Date of Birth'
                      : '${selectedDateOfBirth!.toLocal()}'.split(' ')[0],
                  style: GoogleFonts.cabin(
                    fontSize: 15,
                    color: selectedDateOfBirth == null
                        ? colorScheme.onSurface.withAlpha(150)
                        : colorScheme.onSurface,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: colorScheme.onSurface.withAlpha(150),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Submit Button ────────────────────────────────────────────────

  Widget buildSubmitButton(ColorScheme colorScheme) {
    final isLoading = widget.profileNotifier.isLoading;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: FilledButton(
        onPressed: isLoading ? null : onSubmit,
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.primary.withAlpha(180),
          disabledForegroundColor: colorScheme.onPrimary.withAlpha(200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isLoading ? 0 : 2,
          shadowColor: colorScheme.primary.withAlpha(60),
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onPrimary.withAlpha(200),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Saving...',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
            : Text(
                'Complete Profile',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
