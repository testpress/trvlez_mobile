import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/features/findr/presentation/widgets/finder_onboarding_sheet.dart';

export 'package:trvlez_mobile/features/findr/presentation/widgets/finder_onboarding_sheet.dart';

/// Helper function to display the Findr onboarding and terms sheet.
Future<bool?> showJoinFindrSheet(BuildContext context) {
  return showFinderOnboardingSheet(context);
}

/// Modal or screen allowing verified travelers to review Findr programme
/// terms, enter their residential address, and activate their membership.
class JoinFindrSheet extends StatelessWidget {
  const JoinFindrSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.page,
      body: const SafeArea(
        bottom: false,
        child: FinderOnboardingSheet(isStandalone: true),
      ),
    );
  }
}
