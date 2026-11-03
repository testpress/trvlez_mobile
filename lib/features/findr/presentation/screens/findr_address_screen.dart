import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/errors/app_exception.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/app_pinned_header.dart';
import 'package:trvlez_mobile/features/findr/presentation/providers/findr_providers.dart';
import 'package:trvlez_mobile/features/findr/presentation/widgets/finder_address_step_view.dart';
import 'package:trvlez_mobile/features/findr/presentation/widgets/finder_blocked_view.dart';
import 'package:trvlez_mobile/features/profile/presentation/providers/profile_providers.dart';

/// Screen 4.3 · Step 2 of 2: Findr Residential Address Form.
/// Country is restricted to United Kingdom (GBR).
class FindrAddressScreen extends ConsumerStatefulWidget {
  const FindrAddressScreen({super.key});

  @override
  ConsumerState<FindrAddressScreen> createState() => _FindrAddressScreenState();
}

class _FindrAddressScreenState extends ConsumerState<FindrAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  final _postalCodeController = TextEditingController();

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
    if (form == null || !form.validate() || _isSubmitting) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Findr activated successfully! Welcome to the programme.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go(AppRoutes.findr);
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
          behavior: SnackBarBehavior.floating,
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
    final profileAsync = ref.watch(currentProfileProvider);
    final profile = profileAsync.valueOrNull;
    final finderAsync = ref.watch(finderNotifierProvider);
    final summary = finderAsync.valueOrNull;

    final isBlocked = summary != null && !summary.eligibility.isEligible;

    return Scaffold(
      backgroundColor: colors.page,
      body: Column(
        children: [
          // ── Pinned Header ──────────────────────────────────────────────
          AppPinnedHeader(
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(
                    AppIcons.arrowLeft,
                    size: sizes.iconMd,
                    color: colors.textPrimary,
                  ),
                  tooltip: 'Back',
                ),
                Expanded(
                  child: Text(
                    isBlocked ? 'Programme Status' : 'Residential Address',
                    textAlign: TextAlign.center,
                    style: context.text.titleLarge?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: TypeScale.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: sizes.controlLg),
              ],
            ),
          ),

          // ── Scrollable Form or Blocked View ────────────────────────────
          Expanded(
            child: isBlocked
                ? FinderBlockedView(
                    eligibility: summary.eligibility,
                    onActionCompleted: () => context.pop(),
                  )
                : FinderAddressStepView(
                    formKey: _formKey,
                    addressLine1Controller: _addressLine1Controller,
                    addressLine2Controller: _addressLine2Controller,
                    cityController: _cityController,
                    regionController: _regionController,
                    postalCodeController: _postalCodeController,
                    countryLabel: resolveCountryLabel(profile?.nationality),
                    showHeaderPills: true,
                  ),
          ),

          // ── Sticky Footer ──────────────────────────────────────────────
          if (!isBlocked)
            Container(
              padding: space.insetCard,
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
                    constraints: BoxConstraints(maxWidth: sizes.containerForm),
                    child: AppButton(
                      label: 'Activate Findr',
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _handleActivation,
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

