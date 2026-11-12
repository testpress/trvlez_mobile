import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/app_text_field.dart';
import 'package:trvlez_mobile/features/findr/presentation/providers/findr_providers.dart';

/// Shows the "Refer a Hotel" modal bottom sheet.
Future<bool?> showReferHotelSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.transparent,
    builder: (modalContext) => const ReferHotelBottomSheet(),
  );
}

/// Clean bottom sheet form to submit a prospective hotel partner invitation.
class ReferHotelBottomSheet extends ConsumerStatefulWidget {
  const ReferHotelBottomSheet({super.key});

  @override
  ConsumerState<ReferHotelBottomSheet> createState() =>
      _ReferHotelBottomSheetState();
}

class _ReferHotelBottomSheetState extends ConsumerState<ReferHotelBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _hotelNameController = TextEditingController();
  final _streetAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryCodeController = TextEditingController(text: 'GB');
  final _targetEmailController = TextEditingController();
  final _targetPhoneController = TextEditingController();
  final _personalNoteController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _hotelNameController.dispose();
    _streetAddressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryCodeController.dispose();
    _targetEmailController.dispose();
    _targetPhoneController.dispose();
    _personalNoteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final params = HotelReferralCreateParams(
      hotelName: _hotelNameController.text.trim(),
      streetAddress: _streetAddressController.text.trim(),
      city: _cityController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      countryCode: _countryCodeController.text.trim().toUpperCase(),
      targetEmail: _targetEmailController.text.trim().toLowerCase(),
      targetPhone: _targetPhoneController.text.trim().isEmpty
          ? null
          : _targetPhoneController.text.trim(),
      personalNote: _personalNoteController.text.trim().isEmpty
          ? null
          : _personalNoteController.text.trim(),
    );

    try {
      await ref
          .read(findrPortfolioProvider.notifier)
          .createHotelReferral(params);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hotel referral submitted! Your claim is locked.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      final message = e is AppException ? e.message : e.toString();

      setState(() {
        _isSubmitting = false;
        _errorMessage = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final errorMessage = _errorMessage;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: sizes.containerForm,
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: Container(
          padding: EdgeInsets.only(bottom: bottomInset),
          decoration: BoxDecoration(
            color: colors.page,
            borderRadius: shape.radiusOverlay,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: space.stackTight),
                    width: sizes.controlSm,
                    height: space.stackText,
                    decoration: BoxDecoration(
                      color: colors.line,
                      borderRadius: shape.radiusPill,
                    ),
                  ),
                ),

                // Header
                Padding(
                  padding: space.insetCard,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Refer a Hotel',
                              style: context.text.titleLarge?.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: space.stackTight),
                            Text(
                              'Your claim is locked at the moment you submit',
                              style: context.text.bodySmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          AppIcons.close,
                          size: sizes.iconMd,
                          color: colors.textSecondary,
                        ),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Form content
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: space.insetCard,
                      children: [
                        if (errorMessage != null) ...[
                          Container(
                            padding: space.insetCard,
                            margin: EdgeInsets.only(bottom: space.stackItem),
                            decoration: BoxDecoration(
                              color: colors.feedbackError.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: shape.radiusControl,
                              border: Border.all(
                                color: colors.feedbackError.withValues(
                                  alpha: 0.3,
                                ),
                                width: shape.borderDefault,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  AppIcons.alertTriangle,
                                  color: colors.feedbackError,
                                  size: sizes.iconSm,
                                ),
                                SizedBox(width: space.inlineIconLabel),
                                Expanded(
                                  child: Text(
                                    errorMessage,
                                    style: context.text.bodySmall?.copyWith(
                                      color: colors.feedbackError,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        AppTextField(
                          controller: _hotelNameController,
                          label: 'Hotel Name',
                          hintText: 'e.g. Grand Palace Hotel',
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Hotel name is required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: space.stackItem),

                        AppTextField(
                          controller: _streetAddressController,
                          label: 'Street Address',
                          hintText: 'e.g. 10 High Street',
                          textInputAction: TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.postalAddressExtended,
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Street address is required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: space.stackItem),

                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: AppTextField(
                                controller: _cityController,
                                label: 'City',
                                hintText: 'e.g. London',
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.addressCity,
                                ],
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'City is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: space.inlineIconLabel),
                            Expanded(
                              flex: 2,
                              child: AppTextField(
                                controller: _postalCodeController,
                                label: 'Postal Code',
                                hintText: 'e.g. SW1A 1AA',
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.postalCode],
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Postal code is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: space.stackItem),

                        AppTextField(
                          controller: _countryCodeController,
                          label: 'Country Code (ISO 2-letter)',
                          hintText: 'e.g. GB',
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.countryCode],
                          validator: (value) {
                            if (value == null || value.trim().length != 2) {
                              return 'Enter 2-letter country code (e.g. GB)';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: space.stackItem),

                        AppTextField(
                          controller: _targetEmailController,
                          label: 'Contact Email',
                          hintText: 'e.g. generalmanager@hotel.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Contact email is required';
                            }
                            final emailRegex = RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            );
                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: space.stackItem),

                        AppTextField(
                          controller: _targetPhoneController,
                          label: 'Contact Phone (Optional)',
                          hintText: 'e.g. +44 20 7946 0991',
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.telephoneNumber],
                        ),
                        SizedBox(height: space.stackItem),

                        AppTextField(
                          controller: _personalNoteController,
                          label: 'Personal Note (Optional)',
                          hintText:
                              'e.g. Met the GM during my stay in Interlaken',
                          textInputAction: TextInputAction.done,
                          maxLines: 3,
                        ),
                        SizedBox(height: space.stackSection),

                        AppButton(
                          label: 'Submit Recommendation',
                          isLoading: _isSubmitting,
                          onPressed: _isSubmitting ? null : _submit,
                        ),
                        SizedBox(height: space.stackSection),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
