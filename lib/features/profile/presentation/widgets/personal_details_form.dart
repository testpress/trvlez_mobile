import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
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
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
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
              SizedBox(height: space.stackItem),
              TextFormField(
                controller: phoneController,
                validator: (val) => _validateRequired(val, 'Phone Number'),
                enabled: !isLoading,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumber],
                style: context.text.titleMedium,
                decoration: const InputDecoration(
                  hintText: 'Enter your phone number',
                ),
              ),
            ],
          ),
          SizedBox(height: space.stackFormField),

          // Nationality Picker
          NationalityPickerField(
            selectedNationality: selectedNationality,
            onNationalitySelected: onNationalityChanged,
            isEnabled: !isLoading,
          ),
          SizedBox(height: space.stackFormField),

          // Gender Dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Gender', style: textTheme.labelLarge),
              SizedBox(height: space.stackItem),
              DropdownButtonFormField<String>(
                initialValue: selectedGender,
                isExpanded: true,
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
          SizedBox(height: space.stackFormField),

          // Date of Birth Picker
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date of Birth', style: textTheme.labelLarge),
              SizedBox(height: space.stackItem),
              InkWell(
                onTap: isLoading ? null : () => _selectDateOfBirth(context),
                borderRadius: shape.radiusControl,
                child: Container(
                  padding: space.insetCard,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colors.borderDefault,
                      width: shape.borderDefault,
                    ),
                    borderRadius: shape.radiusControl,
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
                          style: context.text.titleMedium?.copyWith(
                            color: selectedDateOfBirth == null
                                ? colors.textSecondary
                                : colors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: space.inlineIconLabel),
                      Icon(
                        AppIcons.calendar,
                        color: colors.textSecondary,
                        size: sizes.iconMd,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: space.stackFormField),

          // Passport Number Field (Optional)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Passport Number', style: textTheme.labelLarge),
              SizedBox(height: space.stackItem),
              TextFormField(
                controller: passportNumberController,
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
                style: context.text.titleMedium,
                decoration: const InputDecoration(
                  hintText: 'Enter your passport number (optional)',
                ),
              ),
            ],
          ),
          SizedBox(height: space.stackFormField),

          // Passport Expiry Picker (Optional)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Passport Expiry', style: textTheme.labelLarge),
              SizedBox(height: space.stackItem),
              InkWell(
                onTap: isLoading ? null : () => _selectPassportExpiry(context),
                borderRadius: shape.radiusControl,
                child: Container(
                  padding: space.insetCard,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colors.borderDefault,
                      width: shape.borderDefault,
                    ),
                    borderRadius: shape.radiusControl,
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
                          style: context.text.titleMedium?.copyWith(
                            color: selectedPassportExpiry == null
                                ? colors.textSecondary
                                : colors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: space.inlineIconLabel),
                      Icon(
                        AppIcons.calendar,
                        color: colors.textSecondary,
                        size: sizes.iconMd,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: space.stackSection),

          // Complete Profile Submit Button
          AppButton(
            label: 'Complete Profile',
            onPressed: onSubmit,
            isLoading: isLoading,
            height: sizes.controlXl,
          ),
        ],
      ),
    );
  }
}
