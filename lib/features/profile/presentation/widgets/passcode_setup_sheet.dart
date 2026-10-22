import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/features/profile/presentation/providers/security_providers.dart';

/// Modal bottom sheet for configuring local device Keychain app passcode.
class PasscodeSetupSheet extends ConsumerStatefulWidget {
  const PasscodeSetupSheet({super.key, required this.isCurrentlyEnabled});

  final bool isCurrentlyEnabled;

  static Future<void> show(
    BuildContext context, {
    required bool isCurrentlyEnabled,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          PasscodeSetupSheet(isCurrentlyEnabled: isCurrentlyEnabled),
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
    final text = context.text;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(shape.radiusOverlay.topRight.x),
        ),
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
            widget.isCurrentlyEnabled
                ? 'Manage App Passcode'
                : 'Set App Passcode',
            style: text.headlineSmall?.copyWith(color: colors.textPrimary),
          ),
          SizedBox(height: space.stackText),
          Text(
            widget.isCurrentlyEnabled
                ? 'Update or remove the 4-digit PIN locking TRVLez on this phone.'
                : 'Enter a 4-digit PIN to lock TRVLez on this device.',
            style: text.bodyMedium?.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: space.stackFormField),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            maxLength: 4,
            obscureText: true,
            autofocus: true,
            textAlign: TextAlign.center,
            onSubmitted: (_) => _handleSave(),
            style: text.displaySmall?.copyWith(
              letterSpacing: 12,
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
            label: widget.isCurrentlyEnabled
                ? 'Update Passcode'
                : 'Enable Passcode',
            isLoading: _isSubmitting,
            onPressed: _handleSave,
          ),
          if (widget.isCurrentlyEnabled) ...[
            SizedBox(height: space.stackItem),
            TextButton(
              onPressed: _isSubmitting ? null : _handleDisable,
              child: Text(
                'Turn Passcode Off',
                style: text.labelLarge?.copyWith(color: colors.feedbackError),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
