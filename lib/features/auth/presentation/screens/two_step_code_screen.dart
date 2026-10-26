import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_screen.dart';
import 'package:trvlez_mobile/core/widgets/brand_security_note.dart';

/// Two-step 6-digit verification code screen.
class TwoStepCodeScreen extends StatefulWidget {
  const TwoStepCodeScreen({
    super.key,
    this.email = '',
    this.isPasswordReset = false,
  });

  final String email;
  final bool isPasswordReset;

  @override
  State<TwoStepCodeScreen> createState() => _TwoStepCodeScreenState();
}

class _TwoStepCodeScreenState extends State<TwoStepCodeScreen> {
  static const int kResendSeconds = 24;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _timer;
  int _remaining = kResendSeconds;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  void _startTimer() {
    _timer?.cancel();
    _remaining = kResendSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remaining == 0) {
        timer.cancel();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  static String _maskEmail(String email) {
    final atIndex = email.indexOf('@');
    if (atIndex < 3) return email;
    final local = email.substring(0, atIndex);
    return '${local[0]}•••${local[local.length - 1]}${email.substring(atIndex)}';
  }

  void _onVerify() {
    if (_controller.text.length != 6) return;

    if (widget.isPasswordReset) {
      context.pushReplacement(AppRoutes.newPassword);
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final code = _controller.text;

    return BrandScreen(
      onBack: () => context.pop(),
      isScrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'Check your email',
              style: context.text.headlineLarge?.copyWith(
                color: colors.brandOnSurface,
                height: 1.25,
              ),
            ),
          ),
          SizedBox(height: space.stackItem),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'We sent a 6-digit code to ${_maskEmail(widget.email)}',
              style: context.text.bodyLarge?.copyWith(
                color: colors.brandSecondaryBody,
                height: 1.45,
              ),
            ),
          ),

          SizedBox(height: space.stackSection),

          _CodeInputBoxes(
            controller: _controller,
            focusNode: _focusNode,
            code: code,
          ),

          SizedBox(height: space.stackFormField),

          _ResendCountdownRow(remaining: _remaining, onResend: _startTimer),

          const Spacer(),

          const BrandSecurityNote(text: 'Codes expire after 10 minutes.'),

          SizedBox(height: space.stackFormField),

          AppButton(
            label: 'Verify',
            variant: AppButtonVariant.brandWhite,
            active: code.length == 6,
            enabled: code.length == 6,
            onPressed: code.length == 6 ? _onVerify : null,
          ),
        ],
      ),
    );
  }
}

/// Visual 6-box input with responsive flexible sizing and underlying invisible text field.
class _CodeInputBoxes extends StatelessWidget {
  const _CodeInputBoxes({
    required this.controller,
    required this.focusNode,
    required this.code,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String code;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    return Stack(
      children: [
        // Visual 6-box presentation
        Row(
          children: [
            for (var i = 0; i < 6; i++) ...[
              if (i > 0) SizedBox(width: space.stackTight),
              Expanded(
                child: Container(
                  height: sizes.controlMd,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == code.length
                        ? colors.brandCardBackground
                        : colors.brandCodeBoxBackground,
                    borderRadius: shape.radiusControl,
                    border: i == code.length
                        ? Border.all(
                            color: colors.brandOnSurface,
                            width: shape.borderMedium,
                          )
                        : null,
                  ),
                  child: Text(
                    i < code.length ? code[i] : '',
                    style: context.text.headlineMedium?.copyWith(
                      color: colors.brandOnSurface,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),

        // Hidden actual TextField handling input, paste, autofill
        Positioned.fill(
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Standardized resend countdown row with accessible >=48dp touch target and underlined link.
class _ResendCountdownRow extends StatelessWidget {
  const _ResendCountdownRow({required this.remaining, required this.onResend});

  final int remaining;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;

    final isExpired = remaining == 0;
    final label = isExpired
        ? 'Resend'
        : 'Resend in 0:${remaining.toString().padLeft(2, '0')}';

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Didn't get it? ",
              style: context.text.labelMedium?.copyWith(
                color: colors.brandSecondaryBody,
                fontWeight: FontWeight.w400,
              ),
            ),
            Semantics(
              button: true,
              label: label,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: sizes.touchTargetMin,
                  minWidth: sizes.touchTargetMin,
                ),
                child: InkWell(
                  onTap: isExpired ? onResend : null,
                  borderRadius: shape.radiusSubtle,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: space.inlineMicro,
                        vertical: space.stackTight,
                      ),
                      child: Container(
                        padding: EdgeInsets.only(bottom: shape.borderDefault),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: colors.brandUnderline,
                              width: shape.borderDefault,
                            ),
                          ),
                        ),
                        child: Text(
                          label,
                          style: context.text.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.brandOnSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
