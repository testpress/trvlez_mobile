import 'package:flutter/material.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/features/profile/presentation/widgets/detail_row_tile.dart';

/// Card grouping user-editable personal details (display name, email).
class YourDetailsCard extends StatelessWidget {
  const YourDetailsCard({
    super.key,
    required this.displayName,
    required this.email,
    required this.onEditDisplayName,
    required this.onChangeEmail,
  });

  final String displayName;
  final String email;
  final VoidCallback onEditDisplayName;
  final VoidCallback onChangeEmail;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shape = context.shape;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: shape.radiusSurface,
        border: Border.all(
          color: colors.borderSubtle,
          width: shape.borderDefault,
        ),
      ),
      child: Column(
        children: [
          DetailRowTile(
            label: 'Display name',
            value: displayName.isNotEmpty ? displayName : 'Add name',
            actionText: 'Edit',
            onAction: onEditDisplayName,
          ),
          Divider(
            height: 1,
            thickness: shape.borderDefault,
            color: colors.borderSubtle,
          ),
          DetailRowTile(
            label: 'Email',
            value: email.isNotEmpty ? email : 'Add email',
            actionText: 'Change',
            onAction: onChangeEmail,
          ),
        ],
      ),
    );
  }
}
