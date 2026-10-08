import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/core/widgets/app_text_field.dart';
import 'package:trvlez_mobile/features/reservations/presentation/widgets/counter_tile.dart';

/// Form section capturing guest headcount and contact details.
class GuestSelectionSection extends StatelessWidget {
  final int numberOfGuests;
  final VoidCallback onIncrementGuests;
  final VoidCallback? onDecrementGuests;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController specialRequestsController;

  const GuestSelectionSection({
    super.key,
    required this.numberOfGuests,
    required this.onIncrementGuests,
    required this.onDecrementGuests,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.specialRequestsController,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Guest Details',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CounterTile(
          label: 'Guests',
          icon: Icons.person_outline,
          value: numberOfGuests,
          colorScheme: Theme.of(context).colorScheme,
          onIncrement: onIncrementGuests,
          onDecrement: onDecrementGuests,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Primary Guest Name *',
          hintText: 'Enter guest name',
          controller: nameController,
          prefixIcon: const Icon(Icons.badge_outlined, size: 20),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          label: 'Email Address',
          hintText: 'guest@example.com',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined, size: 20),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          label: 'Phone Number',
          hintText: '+1 555-0100',
          controller: phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone_outlined, size: 20),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          label: 'Special Requests',
          hintText: 'Early check-in, dietary preferences...',
          controller: specialRequestsController,
          maxLines: 3,
          prefixIcon: const Icon(Icons.notes_outlined, size: 20),
        ),
      ],
    );
  }
}
