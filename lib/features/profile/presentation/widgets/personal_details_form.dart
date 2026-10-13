import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/features/profile/presentation/widgets/nationality_picker_field.dart';

/// Form section managing traveler's personal details, nationality, and passport information.
class PersonalDetailsForm extends StatelessWidget {
  const PersonalDetailsForm({
    required this.formKey,
    required this.phoneController,
    required this.passportNumberController,
    required this.selectedNationality,
    required this.onNationalityChanged,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.selectedDateOfBirth,
    required this.onDateOfBirthChanged,
    required this.selectedPassportExpiry,
    required this.onPassportExpiryChanged,
    required this.isLoading,
    required this.onSubmit,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final TextEditingController passportNumberController;
  final String? selectedNationality;
  final ValueChanged<String> onNationalityChanged;
  final String? selectedGender;
  final ValueChanged<String?> onGenderChanged;
  final DateTime? selectedDateOfBirth;
  final ValueChanged<DateTime> onDateOfBirthChanged;
  final DateTime? selectedPassportExpiry;
  final ValueChanged<DateTime> onPassportExpiryChanged;
  final bool isLoading;
  final VoidCallback onSubmit;

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      onDateOfBirthChanged(picked);
    }
  }

  Future<void> _selectPassportExpiry(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          selectedPassportExpiry ??
          DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onPassportExpiryChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Phone Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Phone Number', style: textTheme.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: phoneController,
                validator: (val) => _validateRequired(val, 'Phone Number'),
                enabled: !isLoading,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 15,
                ),
                decoration: const InputDecoration(
                  hintText: 'Enter your phone number',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Nationality Picker
          NationalityPickerField(
            selectedNationality: selectedNationality,
            onNationalitySelected: onNationalityChanged,
            isEnabled: !isLoading,
          ),
          const SizedBox(height: AppSpacing.md),

          // Gender Dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Gender', style: textTheme.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: selectedGender,
                decoration: const InputDecoration(
                  hintText: 'Select your gender',
                ),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                  DropdownMenuItem(
                    value: 'prefer_not_to_say',
                    child: Text('Prefer not to say'),
                  ),
                ],
                onChanged: isLoading ? null : onGenderChanged,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Date of Birth Picker
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date of Birth', style: textTheme.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: isLoading ? null : () => _selectDateOfBirth(context),
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.borderDefault),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          selectedDateOfBirth == null
                              ? 'Select Date of Birth'
                              : '${selectedDateOfBirth!.toLocal()}'.split(
                                  ' ',
                                )[0],
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            color: selectedDateOfBirth == null
                                ? colors.textSecondary
                                : colors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(
                        AppIcons.calendar,
                        color: colors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Passport Number Field (Optional)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Passport Number', style: textTheme.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: passportNumberController,
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 15,
                ),
                decoration: const InputDecoration(
                  hintText: 'Enter your passport number (optional)',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Passport Expiry Picker (Optional)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Passport Expiry', style: textTheme.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: isLoading ? null : () => _selectPassportExpiry(context),
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.borderDefault),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          selectedPassportExpiry == null
                              ? 'Select Expiry Date (Optional)'
                              : '${selectedPassportExpiry!.toLocal()}'.split(
                                  ' ',
                                )[0],
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 15,
                            color: selectedPassportExpiry == null
                                ? colors.textSecondary
                                : colors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(
                        AppIcons.calendar,
                        color: colors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Complete Profile Submit Button
          AppButton(
            label: 'Complete Profile',
            onPressed: onSubmit,
            isLoading: isLoading,
            height: 56,
          ),
        ],
      ),
    );
  }
}
