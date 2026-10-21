import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/providers/shared_providers.dart'
    show findrPortfolioProvider;
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/check_in_flag_callout.dart';
import 'package:trvlez_mobile/core/widgets/check_in_notice.dart';
import 'package:trvlez_mobile/features/anywhere/presentation/providers/anywhere_providers.dart';
import 'package:trvlez_mobile/features/anywhere/presentation/widgets/anywhere_widgets.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';

/// Screen 6.2b: Manual property details entry (name, city, recipient email).
class HotelDetailsScreen extends ConsumerStatefulWidget {
  const HotelDetailsScreen({super.key});

  @override
  ConsumerState<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends ConsumerState<HotelDetailsScreen> {
  final _nameController = TextEditingController();
  final _placeController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (final c in [_nameController, _placeController, _emailController]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _nameController.text.trim().isNotEmpty &&
      _emailController.text.trim().contains('@');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final findrPortfolio = ref.watch(findrPortfolioProvider);

    return BrandVerifyScreen(
      title: 'Check in anywhere',
      backgroundAsset: 'assets/art/bg_anywhere.svg',
      helpArea: ProblemArea.checkIn,
      onBack: () => context.pop(),
      isScrollable: true,
      foot: [
        AppButton(
          label: 'Continue',
          variant: AppButtonVariant.brandWhite,
          enabled: _canContinue,
          onPressed: () {
            ref
                .read(anywhereDraftProvider.notifier)
                .setCustomHotel(
                  name: _nameController.text.trim(),
                  place: _placeController.text.trim(),
                  email: _emailController.text.trim(),
                );
            context.push(AppRoutes.anywhereStay);
          },
        ),
        const CheckInNotice(
          text:
              'We need somewhere to send it. A pass the hotel has never heard of helps nobody.',
        ),
      ],
      children: [
        SizedBox(height: space.stackSection),
        Text(
          'Which hotel?',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 22,
            fontWeight: TypeScale.bold,
            color: colors.brandOnSurface,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: space.stackTight),
        Text(
          'We will write to them and ask them to accept your digital pass.',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            color: colors.brandSecondaryBody,
            height: 1.35,
          ),
        ),
        const AnywhereLabel(text: 'Hotel name'),
        AnywhereField(controller: _nameController, hint: 'Hotel Bellavista'),
        const AnywhereLabel(text: 'Town or city'),
        AnywhereField(controller: _placeController, hint: 'Naples, Italy'),
        const AnywhereLabel(
          text: 'Their email',
          hint: 'on your booking confirmation',
        ),
        AnywhereField(
          controller: _emailController,
          hint: 'stay@example-hotel.it',
          keyboard: TextInputType.emailAddress,
        ),
        SizedBox(height: space.stackText),
        if (findrPortfolio.joined)
          CheckInFlagCallout(
            icon: AppIcons.mapSearch,
            lead: 'This goes to your Findr portfolio. ',
            body:
                'If they join TRVLez, you earn 5% of commission on bookings for 12 months.',
            marginTop: space.stackItem,
          )
        else
          AnywhereRow(
            icon: AppIcons.mapSearch,
            title: 'Earn from this introduction',
            subtitle:
                'Join Findr to earn 5% commission if this hotel joins TRVLez',
            chevron: true,
            onTap: () => context.push(AppRoutes.joinFindr),
          ),
      ],
    );
  }
}
