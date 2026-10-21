import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/check_in_consent_tick.dart';
import 'package:trvlez_mobile/core/widgets/check_in_disclosure_card.dart';
import 'package:trvlez_mobile/core/widgets/check_in_flag_callout.dart';
import 'package:trvlez_mobile/core/widgets/check_in_notice.dart';
import 'package:trvlez_mobile/features/anywhere/presentation/providers/anywhere_providers.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';

/// Screen 6.2d: Transparent disclosure overview of what will be transmitted.
class WhatTheyAreToldScreen extends ConsumerStatefulWidget {
  const WhatTheyAreToldScreen({super.key});

  @override
  ConsumerState<WhatTheyAreToldScreen> createState() =>
      _WhatTheyAreToldScreenState();
}

class _WhatTheyAreToldScreenState extends ConsumerState<WhatTheyAreToldScreen> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final draft = ref.watch(anywhereDraftProvider);
    final byEmail = draft.route == AnywhereRoute.byEmail;
    final hotel = draft.hotelName;

    return BrandVerifyScreen(
      title: 'Check in anywhere',
      backgroundAsset: 'assets/art/bg_anywhere.svg',
      helpArea: ProblemArea.checkIn,
      onBack: () => context.pop(),
      isScrollable: true,
      foot: [
        AppButton(
          label: 'Send and continue',
          variant: AppButtonVariant.brandWhite,
          enabled: _agreed,
          onPressed: () {
            ref.read(anywhereDraftProvider.notifier).submit();
            context.pushReplacement(AppRoutes.anywhereSent);
          },
        ),
        const CheckInNotice(text: 'This does not book or confirm anything.'),
      ],
      children: [
        SizedBox(height: space.stackItem),
        Text(
          'What they are told',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 22,
            fontWeight: TypeScale.bold,
            color: colors.brandOnSurface,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: space.stackText),
        Text(
          byEmail ? 'By email, to ${draft.email}' : 'In the $hotel dashboard',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            color: colors.brandSecondaryBody,
            height: 1.35,
          ),
        ),
        SizedBox(height: space.stackText),

        // Disclosure card of sent vs withheld fields
        const CheckInDisclosureCard(
          title: 'We send',
          lines: [
            CheckInDisclosureLine('Your name'),
            CheckInDisclosureLine('Your dates'),
            CheckInDisclosureLine('That TRVLez has verified your ID'),
            CheckInDisclosureLine('Your passport number', shared: false),
            CheckInDisclosureLine('Your documents or photo', shared: false),
            CheckInDisclosureLine(
              'Anyone else staying with you',
              shared: false,
            ),
          ],
        ),

        if (byEmail)
          CheckInFlagCallout(
            icon: AppIcons.scale,
            lead: 'We do not ask them to skip their own checks. ',
            body:
                'Many hotels must see your passport by law. The email says so.',
            marginTop: space.stackFormField,
          )
        else
          CheckInFlagCallout(
            icon: AppIcons.building,
            lead: 'They already use TRVLez. ',
            body:
                'This appears in their dashboard for someone there to link to your reservation.',
            marginTop: space.stackFormField,
          ),

        CheckInConsentTick(
          agreed: _agreed,
          label: 'Send this to $hotel',
          onTap: () => setState(() => _agreed = !_agreed),
        ),
      ],
    );
  }
}
