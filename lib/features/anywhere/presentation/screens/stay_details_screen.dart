import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/check_in_field.dart';
import 'package:trvlez_mobile/core/widgets/check_in_notice.dart';
import 'package:trvlez_mobile/core/widgets/check_in_option_picker_sheet.dart';
import 'package:trvlez_mobile/features/anywhere/presentation/providers/anywhere_providers.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';

/// Screen 6.2c: Dates and guest count selection for external stay.
class StayDetailsScreen extends ConsumerStatefulWidget {
  const StayDetailsScreen({super.key});

  @override
  ConsumerState<StayDetailsScreen> createState() => _StayDetailsScreenState();
}

class _StayDetailsScreenState extends ConsumerState<StayDetailsScreen> {
  static const _dates = [
    '9–12 Nov',
    '14–18 Nov',
    '21–24 Nov',
    '28 Nov – 2 Dec',
  ];

  static const _guestOptions = ['1 adult', '2 adults', '3 adults', '4 adults'];

  String _selectedDates = '';
  int _selectedGuests = 2;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(anywhereDraftProvider);
    _selectedDates = draft.dates.isNotEmpty ? draft.dates : _dates.first;
    _selectedGuests = draft.guests;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final draft = ref.watch(anywhereDraftProvider);

    final hotelSubtitle = draft.place.isNotEmpty
        ? '${draft.hotelName} · ${draft.place}'
        : draft.hotelName;

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
          onPressed: () {
            ref
                .read(anywhereDraftProvider.notifier)
                .setStay(dates: _selectedDates, guests: _selectedGuests);
            context.push(AppRoutes.anywhereTold);
          },
        ),
        const CheckInNotice(
          text: 'Next you will see exactly what they are told.',
        ),
      ],
      children: [
        SizedBox(height: space.stackSection),
        Text(
          'Your stay',
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
          hotelSubtitle,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            color: colors.brandSecondaryBody,
            height: 1.35,
          ),
        ),
        SizedBox(height: space.stackFormField),

        // Date selection
        CheckInField(
          label: 'When are you there?',
          value: _selectedDates,
          onTap: () async {
            final picked = await showCheckInOptionPicker(
              context,
              title: 'When are you there?',
              options: _dates,
              current: _selectedDates,
            );
            if (picked != null) {
              setState(() => _selectedDates = picked);
            }
          },
        ),

        // Guest count selection
        CheckInField(
          label: 'How many guests?',
          value:
              '$_selectedGuests ${_selectedGuests == 1 ? 'adult' : 'adults'}',
          onTap: () async {
            final picked = await showCheckInOptionPicker(
              context,
              title: 'How many guests?',
              options: _guestOptions,
              current:
                  '$_selectedGuests ${_selectedGuests == 1 ? 'adult' : 'adults'}',
            );
            if (picked != null) {
              final count =
                  int.tryParse(picked.split(' ').first) ?? _selectedGuests;
              setState(() => _selectedGuests = count);
            }
          },
        ),
      ],
    );
  }
}
