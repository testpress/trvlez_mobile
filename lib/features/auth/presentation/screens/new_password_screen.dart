import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/brand_screen.dart';
import 'package:trvlez_mobile/core/widgets/brand_security_note.dart';
import 'package:trvlez_mobile/core/widgets/brand_text_field.dart';

/// Screen allowing traveler to choose a new password following a verified reset code.
class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool showMismatch = false;

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_onTextChanged);
    confirmController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (showMismatch) {
      setState(() => showMismatch = false);
    } else {
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    passwordController.removeListener(_onTextChanged);
    confirmController.removeListener(_onTextChanged);
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  bool get isFormFilled =>
      passwordController.text.length >= 8 && confirmController.text.isNotEmpty;

  void _onSubmit() {
    final password = passwordController.text;
    final confirm = confirmController.text;

    if (password.length < 8 || confirm.isEmpty) {
      return;
    }

    if (password != confirm) {
      setState(() => showMismatch = true);
      return;
    }

    // Successfully updated password -> navigate to main flow
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;

    return BrandScreen(
      backgroundAsset: 'assets/art/bg_create_account.svg',
      isScrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            showMismatch ? "Those don't match" : 'Choose a new password',
            style: context.text.headlineLarge?.copyWith(
              color: colors.brandOnSurface,
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: space.stackText),
          Text(
            showMismatch
                ? 'Type the same one in both boxes'
                : "You'll be signed in once it's saved",
            style: context.text.bodyLarge?.copyWith(
              color: colors.brandSecondaryBody,
              height: 1.45,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: space.stackSection),

          BrandTextField(
            label: 'Password',
            placeholder: 'At least 8 characters',
            controller: passwordController,
            obscurable: true,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
          ),

          SizedBox(height: space.stackFormField),

          BrandTextField(
            label: 'Confirm password',
            placeholder: 'Enter it again',
            controller: confirmController,
            obscurable: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            onSubmitted: isFormFilled ? _onSubmit : null,
          ),

          const Spacer(),

          const BrandSecurityNote(
            text:
                'Proprietary ID verification. Encrypted.\nNever shared with external AI.',
          ),

          SizedBox(height: space.stackFormField),

          AppButton(
            label: 'Save and sign in',
            variant: AppButtonVariant.brandWhite,
            active: isFormFilled,
            onPressed: isFormFilled ? _onSubmit : null,
          ),
        ],
      ),
    );
  }
}
