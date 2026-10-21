import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/storage/passcode_storage.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';

/// Modal bottom sheet for configuring local device Keychain app passcode.
class PasscodeSetupSheet extends ConsumerStatefulWidget {
  const PasscodeSetupSheet({super.key, required this.isCurrentlyEnabled});

  final bool isCurrentlyEnabled;

  static Future<void> show(BuildContext context, {required bool isCurrentlyEnabled}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PasscodeSetupSheet(isCurrentlyEnabled: isCurrentlyEnabled),
    );
  }

  @override
  ConsumerState<PasscodeSetupSheet> createState() => _PasscodeSetupSheetState();
}

class _PasscodeSetupSheetState extends ConsumerState<PasscodeSetupSheet> {
  final _controller = TextEditingController();
  String? _error;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final code = _controller.text.trim();
    if (code.length != 4 || int.tryParse(code) == null) {
      setState(() => _error = 'Please enter a 4-digit numeric code');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await ref.read(appPasscodeNotifierProvider.notifier).setPasscode(code);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _error = 'Failed to store passcode securely';
        });
      }
    }
  }

  Future<void> _handleDisable() async {
    setState(() => _isSubmitting = true);
    await ref.read(appPasscodeNotifierProvider.notifier).disablePasscode();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(shape.radiusOverlay.topRight.x)),
      ),
      padding: EdgeInsets.only(
        left: space.insetDialog.left,
        right: space.insetDialog.right,
        top: space.stackSection,
        bottom: MediaQuery.of(context).viewInsets.bottom + space.stackSection,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.isCurrentlyEnabled ? 'Manage App Passcode' : 'Set App Passcode',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 18,
              fontWeight: TypeScale.bold,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: space.stackText),
          Text(
            widget.isCurrentlyEnabled
                ? 'Update or remove the 4-digit PIN locking TRVLez on this phone.'
                : 'Enter a 4-digit PIN to lock TRVLez on this device.',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: space.stackFormField),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            autofocus: true,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 24,
              letterSpacing: 12,
              fontWeight: TypeScale.bold,
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '••••',
              errorText: _error,
            ),
          ),
          SizedBox(height: space.stackSection),
          AppButton(
            label: widget.isCurrentlyEnabled ? 'Update Passcode' : 'Enable Passcode',
            isLoading: _isSubmitting,
            onPressed: _handleSave,
          ),
          if (widget.isCurrentlyEnabled) ...[
            SizedBox(height: space.stackItem),
            TextButton(
              onPressed: _isSubmitting ? null : _handleDisable,
              child: Text(
                'Turn Passcode Off',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  color: colors.feedbackError,
                  fontWeight: TypeScale.semiBold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
