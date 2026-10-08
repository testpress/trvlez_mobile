import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/core/constants/nationalities.dart';

/// Form selector field for choosing traveler nationality with searchable modal sheet.
class NationalityPickerField extends StatelessWidget {
  const NationalityPickerField({
    required this.selectedNationality,
    required this.onNationalitySelected,
    this.isEnabled = true,
    super.key,
  });

  final String? selectedNationality;
  final ValueChanged<String> onNationalitySelected;
  final bool isEnabled;

  Future<void> _showPicker(BuildContext context) async {
    String searchQuery = '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = kNationalities
                .where(
                  (n) => n.toLowerCase().contains(searchQuery.toLowerCase()),
                )
                .toList();

            return FractionallySizedBox(
              heightFactor: 0.8,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  top: AppSpacing.md,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: 'Search Nationality',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        onChanged: (val) =>
                            setSheetState(() => searchQuery = val),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final n = filtered[index];
                          return ListTile(
                            title: Text(n, style: GoogleFonts.cabin()),
                            onTap: () {
                              onNationalitySelected(n);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nationality', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: isEnabled ? () => _showPicker(context) : null,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: colors.borderDefault),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedNationality ?? 'Select Nationality',
                  style: GoogleFonts.cabin(
                    fontSize: 15,
                    color: selectedNationality == null
                        ? colors.textSecondary
                        : colors.textPrimary,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: colorScheme.onSurface.withAlpha(150),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
