import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
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
    final shape = context.shape;
    final sizes = context.sizes;
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

          // ── 6-Box Visual Code Input ──────────────────────────────────
          Stack(
            alignment: Alignment.center,
            children: [
              // Hidden actual TextField handling input, paste, autofill
              Opacity(
                opacity: 0,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                ),
              ),

              // Visual 6-box presentation
              GestureDetector(
                onTap: () => _focusNode.requestFocus(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    final char = index < code.length ? code[index] : '';
                    final isCurrent = index == code.length;

                    return Container(
                      width: sizes.controlMd,
                      height: sizes.controlLg,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? colors.brandCardBackground
                            : colors.brandCodeBoxBackground,
                        borderRadius: shape.radiusControl,
                        border: isCurrent
                            ? Border.all(
                                color: colors.brandOnSurface,
                                width: shape.borderMedium,
                              )
                            : null,
                      ),
                      child: Text(
                        char,
                        style: context.text.headlineMedium?.copyWith(
                          color: colors.brandOnSurface,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),

          SizedBox(height: space.stackSection),

          // ── Resend Line ──────────────────────────────────────────────
          Center(
            child: _remaining > 0
                ? Text(
                    'Resend in 0:${_remaining.toString().padLeft(2, '0')}',
                    style: context.text.labelMedium?.copyWith(
                      color: colors.brandSecondarySmall,
                      fontWeight: TypeScale.regular,
                    ),
                  )
                : Semantics(
                    button: true,
                    label: 'Resend code',
                    child: InkWell(
                      onTap: _startTimer,
                      borderRadius: shape.radiusSubtle,
                      child: Padding(
                        padding: space.insetTag,
                        child: Text(
                          'Resend code',
                          style: context.text.labelMedium?.copyWith(
                            fontWeight: TypeScale.semiBold,
                            color: colors.brandOnSurface,
                            decoration: TextDecoration.underline,
                            decorationColor: colors.brandUnderline,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),

          const Spacer(),

          const BrandSecurityNote(text: 'Codes expire after 10 minutes.'),

          SizedBox(height: space.stackFormField),

          AppButton(
            label: 'Verify',
            variant: AppButtonVariant.brandWhite,
            enabled: code.length == 6,
            onPressed: code.length == 6 ? _onVerify : null,
          ),
        ],
      ),
    );
  }
}
