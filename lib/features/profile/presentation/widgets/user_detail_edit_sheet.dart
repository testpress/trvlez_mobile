import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/features/profile/presentation/providers/profile_providers.dart';

/// Modal bottom sheet for updating user-owned fields (display name or email).
class UserDetailEditSheet extends ConsumerStatefulWidget {
  const UserDetailEditSheet({
    super.key,
    required this.fieldTitle,
    required this.initialValue,
    required this.isEmail,
  });

  final String fieldTitle;
  final String initialValue;
  final bool isEmail;

  static Future<void> show(
    BuildContext context, {
    required String fieldTitle,
    required String initialValue,
    bool isEmail = false,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UserDetailEditSheet(
        fieldTitle: fieldTitle,
        initialValue: initialValue,
        isEmail: isEmail,
      ),
    );
  }

  @override
  ConsumerState<UserDetailEditSheet> createState() =>
      _UserDetailEditSheetState();
}

class _UserDetailEditSheetState extends ConsumerState<UserDetailEditSheet> {
  late final TextEditingController _controller;
  String? _error;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      setState(() => _error = '${widget.fieldTitle} cannot be empty');
      return;
    }

    if (widget.isEmail && !value.contains('@')) {
      setState(() => _error = 'Please enter a valid email address');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await ref
        .read(currentProfileProvider.notifier)
        .updateUserDetails(
          displayName: widget.isEmail ? null : value,
          email: widget.isEmail ? value : null,
        );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Failed to update ${widget.fieldTitle.toLowerCase()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final shape = context.shape;

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
            'Edit ${widget.fieldTitle}',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 18,
              fontWeight: TypeScale.bold,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: space.stackText),
          Text(
            widget.isEmail
                ? 'Your email is used for booking confirmations and account sign-in.'
                : 'Your display name is how TRVLez greets you across the app.',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: space.stackFormField),
          TextField(
            controller: _controller,
            keyboardType: widget.isEmail
                ? TextInputType.emailAddress
                : TextInputType.name,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter ${widget.fieldTitle.toLowerCase()}',
              errorText: _error,
            ),
          ),
          SizedBox(height: space.stackSection),
          AppButton(
            label: 'Save Changes',
            isLoading: _isLoading,
            onPressed: _handleSave,
          ),
        ],
      ),
    );
  }
}
