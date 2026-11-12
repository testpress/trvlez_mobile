import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/providers/shared_providers.dart';
import 'package:trvlez_mobile/core/utils/date_formatter.dart';
import 'package:trvlez_mobile/core/utils/price_formatter.dart';
import 'package:trvlez_mobile/core/widgets/app_pinned_header.dart';
import 'package:trvlez_mobile/features/booking/presentation/providers/booking_providers.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_app_button.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_light_field.dart';
import 'package:trvlez_mobile/features/booking/presentation/widgets/booking_note_card.dart';

/// Screen collecting and tokenizing payment card details for a reservation.
class BookingCardScreen extends ConsumerStatefulWidget {
  const BookingCardScreen({super.key});

  @override
  ConsumerState<BookingCardScreen> createState() => _BookingCardScreenState();
}

class _BookingCardScreenState extends ConsumerState<BookingCardScreen> {
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _codeController = TextEditingController();
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final verState = ref.read(verificationNotifierProvider);
    final mrz = verState.mrzExtractionResult;
    final nfc = verState.nfcResult;
    final firstName = nfc?.parsedMrz?.firstName ?? mrz?.firstName;
    final lastName = nfc?.parsedMrz?.lastName ?? mrz?.lastName;
    final fullName = [
      firstName,
      lastName,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' ');

    _nameController = TextEditingController(text: fullName);
    for (final c in [
      _numberController,
      _expiryController,
      _codeController,
      _nameController,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _expiryController.dispose();
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool get _isFilled =>
      _numberController.text.trim().isNotEmpty &&
      _expiryController.text.trim().isNotEmpty &&
      _codeController.text.trim().isNotEmpty &&
      _nameController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final draft = ref.watch(bookingDraftProvider);
    final deadline = (draft != null && draft.ranges.isNotEmpty)
        ? draft.ranges.first.freeCancellationUntil
        : null;

    return Scaffold(
      backgroundColor: colors.page,
      body: Column(
        children: [
          AppPinnedHeader(
            child: Row(
              children: [
                Semantics(
                  button: true,
                  label: 'Back',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.pop(),
                    child: Padding(
                      padding: EdgeInsets.all(space.stackText),
                      child: Icon(
                        AppIcons.arrowLeft,
                        size: sizes.iconMd,
                        color: colors.ink,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: space.inlineIconLabel),
                Text(
                  'Payment',
                  style: context.text.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.ink,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: space.stackFormField),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: space.insetCard.left,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        BookingLightField(
                          label: 'Card number',
                          controller: _numberController,
                          hint: '1234 5678 9012 3456',
                          keyboard: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.creditCardNumber],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: BookingLightField(
                                label: 'Expiry',
                                controller: _expiryController,
                                hint: 'MM / YY',
                                keyboard: TextInputType.datetime,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.creditCardExpirationDate,
                                ],
                              ),
                            ),
                            SizedBox(width: space.inlineIconLabel),
                            Expanded(
                              child: BookingLightField(
                                label: 'Security code',
                                controller: _codeController,
                                hint: 'CVC',
                                keyboard: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.creditCardSecurityCode,
                                ],
                              ),
                            ),
                          ],
                        ),
                        BookingLightField(
                          label: 'Name on card',
                          controller: _nameController,
                          hint: 'As printed on the card',
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.name],
                        ),
                      ],
                    ),
                  ),
                  const _CardAssuranceNotice(),
                  if (draft != null)
                    BookingNoteCard(
                      amber: true,
                      title: deadline == null
                          ? '${PriceFormatter.formatPrice(draft.total.toDouble(), currencyCode: draft.currencyCode)} when you confirm'
                          : '${PriceFormatter.formatPrice(draft.total.toDouble(), currencyCode: draft.currencyCode)} on ${DateFormatter.dayMonth(deadline)}',
                      body: deadline == null
                          ? 'This stay starts too soon for a free-cancellation period. We check the card is live and take payment on confirmation. Your bank may ask you to approve it.'
                          : 'We check the card is live today and take payment when free cancellation ends. Your bank may ask you to approve it.',
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              space.insetCard.left,
              space.stackItem,
              space.insetCard.right,
              space.insetCard.bottom,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(
                top: BorderSide(color: colors.line, width: shape.borderDefault),
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.cardShadow,
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BookingAppButton(
                    label: 'Save card',
                    onPressed: _isFilled
                        ? () {
                            ref
                                .read(bookingDraftProvider.notifier)
                                .addBookingCard();
                            context.pop();
                          }
                        : null,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: space.stackItem),
                    child: Text(
                      deadline == null
                          ? 'Nothing is taken until you confirm.'
                          : 'Nothing is taken today.',
                      textAlign: TextAlign.center,
                      style: context.text.labelMedium?.copyWith(
                        color: colors.inkTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardAssuranceNotice extends StatelessWidget {
  const _CardAssuranceNotice();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Container(
      margin: EdgeInsets.fromLTRB(
        space.insetCard.left,
        space.stackFormField,
        space.insetCard.right,
        0,
      ),
      padding: space.insetCard,
      decoration: BoxDecoration(
        color: colors.okFill,
        borderRadius: shape.radiusSurface,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(AppIcons.shieldCheck, size: sizes.iconSm, color: colors.okInk),
          SizedBox(width: space.inlineIconLabel),
          Expanded(
            child: Text(
              'We never see or store your card. It is held by our payment provider.',
              style: context.text.labelMedium?.copyWith(color: colors.okInk),
            ),
          ),
        ],
      ),
    );
  }
}
