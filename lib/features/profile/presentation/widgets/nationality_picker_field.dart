import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
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
    final space = context.space;
    final shape = context.shape;
    String searchQuery = '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: shape.radiusOverlay.topLeft,
          topRight: shape.radiusOverlay.topRight,
        ),
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
                  top: space.stackFormField,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: space.insetCard.left,
                      ),
                      child: TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: 'Search Nationality',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: shape.radiusControl,
                          ),
                        ),
                        onChanged: (val) =>
                            setSheetState(() => searchQuery = val),
                      ),
                    ),
                    SizedBox(height: space.stackItem),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final n = filtered[index];
                          return ListTile(
                            title: Text(n, style: context.text.bodyMedium),
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
    final space = context.space;
    final shape = context.shape;
    final sizes = context.sizes;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nationality', style: Theme.of(context).textTheme.labelLarge),
        SizedBox(height: space.stackItem),
        InkWell(
          onTap: isEnabled ? () => _showPicker(context) : null,
          borderRadius: shape.radiusControl,
          child: Container(
            padding: space.insetCard,
            decoration: BoxDecoration(
              border: Border.all(
                color: colors.borderDefault,
                width: shape.borderDefault,
              ),
              borderRadius: shape.radiusControl,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selectedNationality ?? 'Select Nationality',
                    style: context.text.titleMedium?.copyWith(
                      color: selectedNationality == null
                          ? colors.textSecondary
                          : colors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  AppIcons.chevronDown,
                  color: colorScheme.onSurface.withAlpha(150),
                  size: sizes.iconMd,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
