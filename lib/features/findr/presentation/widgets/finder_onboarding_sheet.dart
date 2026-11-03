import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/status_pill.dart';
import 'package:trvlez_mobile/features/findr/presentation/providers/findr_providers.dart';
import 'package:trvlez_mobile/features/findr/presentation/widgets/finder_address_step_view.dart';
import 'package:trvlez_mobile/features/findr/presentation/widgets/finder_blocked_view.dart';
import 'package:trvlez_mobile/features/findr/presentation/widgets/finder_terms_step_view.dart';
import 'package:trvlez_mobile/features/profile/presentation/providers/profile_providers.dart';

/// Modal bottom sheet guiding eligible travelers through the 2-step Findr onboarding:
/// Step 1: Versioned Terms & Participation Agreement
/// Step 2: Residential Address locked to United Kingdom (GBR)
Future<bool?> showFinderOnboardingSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (modalContext) => const FinderOnboardingSheet(),
  );
}

enum _OnboardingStep {
  terms,
  address,
}

class FinderOnboardingSheet extends ConsumerStatefulWidget {
  const FinderOnboardingSheet({
    super.key,
    this.isStandalone = false,
  });

  final bool isStandalone;

  @override
  ConsumerState<FinderOnboardingSheet> createState() =>
      _FinderOnboardingSheetState();
}

class _FinderOnboardingSheetState extends ConsumerState<FinderOnboardingSheet> {
  final _formKey = GlobalKey<FormState>();

  _OnboardingStep _currentStep = _OnboardingStep.terms;

  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  final _postalCodeController = TextEditingController();

  bool _termsAgreed = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleActivation() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate() || !_termsAgreed || _isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);

    final terms = ref.read(finderTermsProvider);
    final agreementVersion = terms.version;

    final profile = ref.read(currentProfileProvider).valueOrNull;
    final countryCode = resolveCountryCode(profile?.nationality);

    final params = FinderActivationParams(
      addressLine1: _addressLine1Controller.text.trim(),
      addressLine2: _addressLine2Controller.text.trim().isEmpty
          ? null
          : _addressLine2Controller.text.trim(),
      city: _cityController.text.trim(),
      region: _regionController.text.trim().isEmpty
          ? null
          : _regionController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      residentialCountryCode: countryCode,
      agreementVersion: agreementVersion,
      agreementAccepted: true,
    );

    final isSuccess =
        await ref.read(finderNotifierProvider.notifier).activate(params);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (isSuccess) {
      ref.read(findrPortfolioProvider.notifier).joinFindr();
      Navigator.of(context).pop(true);
    } else {
      final state = ref.read(finderNotifierProvider);
      final error = state.error;
      final errorMessage = error is AppException
          ? error.message
          : (state.hasError
              ? state.error.toString()
              : 'Activation failed. Please check your address and try again.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: context.colors.feedbackError,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final mediaQuery = MediaQuery.of(context);
    final terms = ref.watch(finderTermsProvider);
    final finderAsync = ref.watch(finderNotifierProvider);
    final summary = finderAsync.valueOrNull;
    final profileAsync = ref.watch(currentProfileProvider);
    final profile = profileAsync.valueOrNull;

    final isBlocked = summary != null && !summary.eligibility.isEligible;

    final sheetContent = Container(
      constraints: BoxConstraints(
        maxHeight: widget.isStandalone
            ? double.infinity
            : mediaQuery.size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: colors.page,
        borderRadius: widget.isStandalone
            ? BorderRadius.zero
            : BorderRadius.vertical(
                top: Radius.circular(shape.radiusSurface.topLeft.x * 1.5),
              ),
      ),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          mainAxisSize:
              widget.isStandalone ? MainAxisSize.max : MainAxisSize.min,
          children: [
            // ── Drag Handle (Sheet only) ──────────────────────────────────
            if (!widget.isStandalone)
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: space.stackItem),
                  width: sizes.controlLg,
                  height: shape.borderMedium * 2,
                  decoration: BoxDecoration(
                    color: colors.borderDefault,
                    borderRadius: shape.radiusControlSm,
                  ),
                ),
              ),

            // ── Header Bar ────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: space.insetCard.left,
                vertical: space.stackItem,
              ),
              child: Row(
                children: [
                  if (!isBlocked && _currentStep == _OnboardingStep.address) ...[
                    IconButton(
                      onPressed: () {
                        setState(() => _currentStep = _OnboardingStep.terms);
                      },
                      icon: Icon(
                        AppIcons.arrowLeft,
                        size: sizes.iconSm,
                        color: colors.textPrimary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Back to Terms',
                    ),
                    SizedBox(width: space.inlineItem),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            StatusPill(
                              label: isBlocked
                                  ? 'Status'
                                  : (_currentStep == _OnboardingStep.terms
                                      ? 'Step 1 of 2'
                                      : 'Step 2 of 2'),
                              state: StatusPillState.awaiting,
                            ),
                            SizedBox(width: space.inlineItem),
                            Expanded(
                              child: Text(
                                isBlocked
                                    ? 'Findr Programme'
                                    : (_currentStep == _OnboardingStep.terms
                                        ? 'Terms of Participation'
                                        : 'Residential Address'),
                                style: context.text.labelMedium?.copyWith(
                                  color: colors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: space.stackText),
                        Text(
                          isBlocked
                              ? 'Programme Eligibility'
                              : (_currentStep == _OnboardingStep.terms
                                  ? 'Findr Agreement'
                                  : (resolveCountryCode(profile?.nationality) == 'GB'
                                      ? 'UK Residential Address'
                                      : 'Residential Address')),
                          style: context.text.titleLarge?.copyWith(
                            color: colors.textPrimary,
                            fontWeight: TypeScale.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: Icon(
                      AppIcons.x,
                      size: sizes.iconSm,
                      color: colors.textSecondary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: shape.borderDefault,
              color: colors.borderSubtle,
            ),

            // ── Step Content ───────────────────────────────────────────────
            Expanded(
              child: isBlocked
                  ? FinderBlockedView(
                      eligibility: summary.eligibility,
                      onActionCompleted: () => Navigator.of(context).pop(),
                    )
                  : (_currentStep == _OnboardingStep.terms
                      ? FinderTermsStepView(
                          terms: terms,
                          hasAcceptedTerms: _termsAgreed,
                          onAcceptanceChanged: (value) {
                            setState(() => _termsAgreed = value);
                          },
                        )
                      : FinderAddressStepView(
                          formKey: _formKey,
                          addressLine1Controller: _addressLine1Controller,
                          addressLine2Controller: _addressLine2Controller,
                          cityController: _cityController,
                          regionController: _regionController,
                          postalCodeController: _postalCodeController,
                          countryLabel: resolveCountryLabel(profile?.nationality),
                        )),
            ),

            // ── Sticky Footer ──────────────────────────────────────────────
            if (!isBlocked)
              Container(
                padding: EdgeInsets.fromLTRB(
                  space.insetCard.left,
                  space.stackItem,
                  space.insetCard.right,
                  space.stackItem + mediaQuery.viewInsets.bottom,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border(
                    top: BorderSide(
                      color: colors.borderSubtle,
                      width: shape.borderDefault,
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: sizes.containerForm),
                      child: _currentStep == _OnboardingStep.terms
                          ? AppButton(
                              label: 'Continue to Address',
                              icon: Icon(
                                AppIcons.arrowRight,
                                size: sizes.iconSm,
                                color: colors.textOnAction,
                              ),
                              onPressed: _termsAgreed
                                  ? () {
                                      setState(() {
                                        _currentStep = _OnboardingStep.address;
                                      });
                                    }
                                  : null,
                            )
                          : AppButton(
                              label: 'Activate Findr',
                              isLoading: _isSubmitting,
                              onPressed:
                                  _isSubmitting ? null : _handleActivation,
                            ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return sheetContent;
  }
}
