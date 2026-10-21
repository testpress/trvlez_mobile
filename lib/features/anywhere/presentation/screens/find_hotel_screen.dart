import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_typography.dart';
import 'package:trvlez_mobile/app/theme/tokens/primitives/type_scale.dart';
import 'package:trvlez_mobile/core/widgets/brand_verify_screen.dart';
import 'package:trvlez_mobile/core/widgets/check_in_notice.dart';
import 'package:trvlez_mobile/features/anywhere/presentation/providers/anywhere_providers.dart';
import 'package:trvlez_mobile/features/anywhere/presentation/widgets/anywhere_widgets.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';

/// Screen 6.2a: Search for partner properties or begin manual property registration.
class FindHotelScreen extends ConsumerStatefulWidget {
  const FindHotelScreen({super.key});

  @override
  ConsumerState<FindHotelScreen> createState() => _FindHotelScreenState();
}

class _FindHotelScreenState extends ConsumerState<FindHotelScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final query = _searchController.text.trim().toLowerCase();
    final results = kHotelDirectory
        .where(
          (h) =>
              h.name.toLowerCase().contains(query) ||
              h.place.toLowerCase().contains(query),
        )
        .toList();

    return BrandVerifyScreen(
      title: 'Check in anywhere',
      backgroundAsset: 'assets/art/bg_anywhere.svg',
      helpArea: ProblemArea.checkIn,
      onBack: () => context.pop(),
      isScrollable: true,
      foot: const [
        CheckInNotice(text: 'Nothing reaches any hotel until you confirm it.'),
      ],
      children: [
        SizedBox(height: space.stackSection),
        Text(
          'Find your hotel',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 22,
            fontWeight: TypeScale.bold,
            color: colors.brandOnSurface,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: space.stackTight),
        Text(
          'You do not need to have booked through us. Being verified is enough.',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            color: colors.brandSecondaryBody,
            height: 1.35,
          ),
        ),
        SizedBox(height: space.stackFormField),

        // Search input
        AnywhereField(
          controller: _searchController,
          hint: 'Hotel name or city',
          icon: AppIcons.search,
          onClear: _searchController.clear,
        ),
        SizedBox(height: space.stackFormField),

        // Partner hotel results
        for (final hotel in results)
          AnywhereRow(
            icon: AppIcons.building,
            title: hotel.name,
            subtitle: hotel.place,
            tag: 'On TRVLez',
            onTap: () {
              ref.read(anywhereDraftProvider.notifier).begin();
              ref.read(anywhereDraftProvider.notifier).pickHotel(hotel);
              context.push(AppRoutes.anywhereStay);
            },
          ),

        // Manual registration option
        AnywhereRow(
          icon: AppIcons.alertTriangle,
          title: 'Not in the list?',
          subtitle: 'Type the hotel and we will contact them',
          chevron: true,
          onTap: () {
            ref.read(anywhereDraftProvider.notifier).begin();
            context.push(AppRoutes.anywhereHotel);
          },
        ),
      ],
    );
  }
}
