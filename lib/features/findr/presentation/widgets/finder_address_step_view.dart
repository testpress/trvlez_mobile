import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_text_field.dart';
import 'package:trvlez_mobile/core/widgets/status_pill.dart';

/// Step 2 view: Structured residential address form restricted to United Kingdom (GBR).
class FinderAddressStepView extends StatelessWidget {
  const FinderAddressStepView({
    super.key,
    required this.formKey,
    required this.addressLine1Controller,
    required this.addressLine2Controller,
    required this.cityController,
    required this.regionController,
    required this.postalCodeController,
    this.showHeaderPills = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController addressLine1Controller;
  final TextEditingController addressLine2Controller;
  final TextEditingController cityController;
  final TextEditingController regionController;
  final TextEditingController postalCodeController;
  final bool showHeaderPills;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: sizes.containerForm),
        child: Form(
          key: formKey,
          child: AutofillGroup(
            child: ListView(
              padding: space.insetCard,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                if (showHeaderPills) ...[
                  Row(
                    children: [
                      const StatusPill(
                        label: 'Step 2 of 2',
                        state: StatusPillState.awaiting,
                      ),
                      SizedBox(width: space.inlineItem),
                      Expanded(
                        child: Text(
                          'Residential Address',
                          style: context.text.labelMedium?.copyWith(
                            color: colors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: space.stackItem),
                  Text(
                    'Where are you based?',
                    style: context.text.headlineSmall?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: TypeScale.bold,
                    ),
                  ),
                  SizedBox(height: space.stackText),
                  Text(
                    'Enter your residential address in the United Kingdom. This is used for programme compliance and payout verification.',
                    style: context.text.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: space.stackSection),
                ],

                // Locked Country Notice
                Container(
                  padding: space.insetCard,
                  decoration: BoxDecoration(
                    color: colors.surfaceSubtle,
                    borderRadius: shape.radiusSurface,
                    border: Border.all(
                      color: colors.borderSubtle,
                      width: shape.borderDefault,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        AppIcons.mapPin,
                        size: sizes.iconSm,
                        color: colors.brandPrimary,
                      ),
                      SizedBox(width: space.inlineItem),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Country / Market',
                              style: context.text.labelSmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                            SizedBox(height: space.stackTight),
                            Text(
                              'United Kingdom (GBR)',
                              style: context.text.titleSmall?.copyWith(
                                color: colors.textPrimary,
                                fontWeight: TypeScale.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        AppIcons.lock,
                        size: sizes.iconSm,
                        color: colors.textSecondary,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: space.stackItem),

                // Address Line 1
                AppTextField(
                  label: 'Address Line 1',
                  controller: addressLine1Controller,
                  hintText: 'e.g. 10 Downing Street',
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.streetAddressLine1],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Address Line 1 is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: space.stackItem),

                // Address Line 2
                AppTextField(
                  label: 'Address Line 2 (Optional)',
                  controller: addressLine2Controller,
                  hintText: 'Apartment, suite, or unit',
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.streetAddressLine2],
                ),
                SizedBox(height: space.stackItem),

                // City
                AppTextField(
                  label: 'Town / City',
                  controller: cityController,
                  hintText: 'e.g. London',
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.addressCity],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'City is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: space.stackItem),

                // Region
                AppTextField(
                  label: 'County / Region (Optional)',
                  controller: regionController,
                  hintText: 'e.g. Greater London',
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.addressState],
                ),
                SizedBox(height: space.stackItem),

                // Postcode
                AppTextField(
                  label: 'Postcode',
                  controller: postalCodeController,
                  hintText: 'e.g. SW1A 2AA',
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.postalCode],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Postcode is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: space.stackSection),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
