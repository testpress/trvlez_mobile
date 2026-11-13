import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/utils/app_logger.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/app_error_banner.dart';
import 'package:trvlez_mobile/core/widgets/app_text_field.dart';
import 'package:trvlez_mobile/features/findr/presentation/providers/findr_providers.dart';

/// Consolidated form for recommending a prospective hotel partner.
///
/// **Contract:**
/// - **Owner:** Findr hotel referral feature (`lib/features/findr/presentation/widgets/refer_hotel_form.dart`).
/// - **Role:** Reusable form with validation, submission, and error handling for hotel recommendations.
/// - **Validation Owner:** `test/features/findr/presentation/widgets/refer_hotel_bottom_sheet_test.dart`.
class ReferHotelForm extends ConsumerStatefulWidget {
  const ReferHotelForm({
    super.key,
    this.onSuccess,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  final VoidCallback? onSuccess;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  @override
  ConsumerState<ReferHotelForm> createState() => _ReferHotelFormState();
}

class _ReferHotelFormState extends ConsumerState<ReferHotelForm> {
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

      if (widget.onSuccess != null) {
        widget.onSuccess!();
      } else {
        Navigator.of(context).pop(true);
      }
    } catch (error, stackTrace) {
      AppLogger.warning('Failed to submit hotel referral', error, stackTrace);
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _errorMessage = AppException.userMessage(
          error,
          'Failed to submit referral. Please try again.',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final space = context.space;

    return Form(
      key: _formKey,
      child: ListView(
        padding: widget.padding ?? space.insetCard,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        children: [
          AppErrorBanner(
            message: _errorMessage,
            onDismiss: () => setState(() => _errorMessage = null),
          ),
          AppTextField(
            controller: _hotelNameController,
            label: 'Hotel Name',
            hintText: 'e.g. Grand Palace Hotel',
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Hotel name is required'
                : null,
          ),
          SizedBox(height: space.stackItem),
          AppTextField(
            controller: _streetAddressController,
            label: 'Street Address',
            hintText: 'e.g. 10 High Street',
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.postalAddressExtended],
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Street address is required'
                : null,
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
                  autofillHints: const [AutofillHints.addressCity],
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'City is required'
                      : null,
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
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Postal code is required'
                      : null,
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
            validator: (v) => (v == null || v.trim().length != 2)
                ? 'Enter 2-letter country code (e.g. GB)'
                : null,
          ),
          SizedBox(height: space.stackItem),
          AppTextField(
            controller: _targetEmailController,
            label: 'Contact Email',
            hintText: 'e.g. generalmanager@hotel.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Contact email is required';
              }
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
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
            hintText: 'e.g. Met the GM during my stay in Interlaken',
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
    );
  }
}
