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
import 'package:trvlez_mobile/core/widgets/error_view.dart';
import 'package:trvlez_mobile/core/widgets/loading_view.dart';
import 'package:trvlez_mobile/features/check_in/presentation/providers/check_in_providers.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';

/// Screen 5.5: Property arrival time, guest count, and optional traveler notes form.
class CheckInQuestionsScreen extends ConsumerStatefulWidget {
  const CheckInQuestionsScreen({super.key, required this.reservationId});

  final String reservationId;

  @override
  ConsumerState<CheckInQuestionsScreen> createState() =>
      _CheckInQuestionsScreenState();
}

class _CheckInQuestionsScreenState
    extends ConsumerState<CheckInQuestionsScreen> {
  static const _arrivalTimes = [
    'Before noon',
    'Around 2pm',
    'Around 4pm',
    'Around 6pm',
    'Around 8pm',
    'After 10pm',
    "I'm not sure yet",
  ];

  static const _guestOptions = ['1 adult', '2 adults', '3 adults', '4 adults'];

  String _arrival = 'Around 6pm';
  int _guests = 2;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final stateAsync = ref.watch(checkInNotifierProvider(widget.reservationId));

    return stateAsync.when(
      loading: () => Scaffold(
        backgroundColor: colors.brandSurface,
        body: const Center(child: LoadingView()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: colors.brandSurface,
        body: Center(
          child: ErrorView(
            message: err.toString(),
            onRetry: () =>
                ref.invalidate(checkInNotifierProvider(widget.reservationId)),
          ),
        ),
      ),
      data: (details) {
        if (_guests == 2 && details.numberOfGuests > 0) {
          _guests = details.numberOfGuests;
        }

        return BrandVerifyScreen(
          title: 'Online check-in',
          backgroundAsset: 'assets/art/bg_checkin_flow.svg',
          helpArea: ProblemArea.checkIn,
          onBack: () => context.pop(),
          isScrollable: true,
          foot: [
            AppButton(
              label: 'Finish check-in',
              variant: AppButtonVariant.brandWhite,
              onPressed: () async {
                final notifier = ref.read(
                  checkInNotifierProvider(widget.reservationId).notifier,
                );
                notifier.updateQuestions(
                  arrivalTime: _arrival,
                  numberOfGuests: _guests,
                  note: _noteController.text,
                );
                await notifier.finishCheckIn();
                if (context.mounted) {
                  context.pushReplacement(
                    AppRoutes.checkInDonePath(widget.reservationId),
                  );
                }
              },
            ),
            const CheckInNotice(
              text: 'The hotel is told once you finish, not before.',
            ),
          ],
          children: [
            SizedBox(height: space.stackSection),
            Text(
              'A few questions',
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
              'So the hotel has your room ready when you arrive.',
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                color: colors.brandSecondaryBody,
                height: 1.35,
              ),
            ),
            SizedBox(height: space.stackFormField),

            // Arrival time picker
            CheckInField(
              label: 'What time will you arrive?',
              value: _arrival,
              onTap: () async {
                final picked = await showCheckInOptionPicker(
                  context,
                  title: 'What time will you arrive?',
                  options: _arrivalTimes,
                  current: _arrival,
                );
                if (picked != null && mounted) {
                  setState(() => _arrival = picked);
                }
              },
            ),

            // Guest count picker
            CheckInField(
              label: 'How many guests?',
              value: '$_guests ${_guests == 1 ? 'adult' : 'adults'}',
              onTap: () async {
                final picked = await showCheckInOptionPicker(
                  context,
                  title: 'How many guests?',
                  options: _guestOptions,
                  current: '$_guests ${_guests == 1 ? 'adult' : 'adults'}',
                );
                if (picked != null && mounted) {
                  final count =
                      int.tryParse(picked.split(' ').first) ?? _guests;
                  setState(() => _guests = count);
                }
              },
            ),

            // Special notes textfield
            CheckInField(
              label: 'Anything they should know? Optional',
              value: '',
              tall: true,
              controller: _noteController,
              hint: 'Quiet room if possible…',
            ),
          ],
        );
      },
    );
  }
}
