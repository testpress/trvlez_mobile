import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';
import 'package:trvlez_mobile/core/widgets/loading_view.dart';
import 'package:trvlez_mobile/features/booking/presentation/screens/property_screen.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';
import 'package:trvlez_mobile/features/properties/domain/repositories/properties_repository.dart';
import 'package:trvlez_mobile/features/properties/presentation/providers/properties_providers.dart';
import 'package:trvlez_mobile/features/properties/presentation/widgets/property_content_sheet.dart';
import 'package:trvlez_mobile/features/properties/presentation/widgets/property_header_image.dart';
import 'package:trvlez_mobile/features/properties/presentation/widgets/property_top_bar.dart';

/// Screen displaying comprehensive details and room selections for a single property.
class PropertyDetailScreen extends StatelessWidget {
  final String propertyId;
  final Property? property;
  final PropertiesRepository? repository;

  PropertyDetailScreen({
    super.key,
    String? propertyId,
    this.property,
    this.repository,
  }) : propertyId = propertyId ?? property?.id ?? '';

  @override
  Widget build(BuildContext context) {
    if (repository != null) {
      return ProviderScope(
        overrides: [
          propertiesRepositoryProvider.overrideWithValue(repository!),
        ],
        child: _PropertyDetailView(
          propertyId: propertyId,
          initialProperty: property,
        ),
      );
    }

    return PropertyScreen(property: property);
  }
}

class _PropertyDetailView extends ConsumerStatefulWidget {
  final String propertyId;
  final Property? initialProperty;

  const _PropertyDetailView({required this.propertyId, this.initialProperty});

  @override
  ConsumerState<_PropertyDetailView> createState() =>
      _PropertyDetailViewState();
}

class _PropertyDetailViewState extends ConsumerState<_PropertyDetailView> {
  final ScrollController _scrollController = ScrollController();
  bool _isFavorite = false;
  String? _selectedRoomTypeId;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onRoomTypeSelected(String roomTypeId) {
    setState(() {
      _selectedRoomTypeId = (_selectedRoomTypeId == roomTypeId)
          ? null
          : roomTypeId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final asyncProperty = ref.watch(
      propertyDetailNotifierProvider(widget.propertyId),
    );

    final displayProperty = asyncProperty.valueOrNull ?? widget.initialProperty;

    if (displayProperty == null && asyncProperty.isLoading) {
      return const Scaffold(
        body: LoadingView(message: 'Loading property details...'),
      );
    }

    if (displayProperty == null && asyncProperty.hasError) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: ErrorView(
          title: 'Unable to load property',
          message: asyncProperty.error.toString(),
          onRetry: () => ref
              .read(propertyDetailNotifierProvider(widget.propertyId).notifier)
              .refresh(),
        ),
      );
    }

    if (displayProperty == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: ErrorView(
          title: 'Property Not Found',
          message: 'The requested property could not be found.',
          onRetry: () => ref
              .read(propertyDetailNotifierProvider(widget.propertyId).notifier)
              .refresh(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          PropertyHeaderImage(property: displayProperty),
          PropertyTopBar(
            isFavorite: _isFavorite,
            onFavoriteToggle: () => setState(() => _isFavorite = !_isFavorite),
          ),
          PropertyContentSheet(
            property: displayProperty,
            isEnriching: asyncProperty.isLoading,
            scrollController: _scrollController,
            selectedRoomTypeId: _selectedRoomTypeId,
            onRoomTypeSelected: _onRoomTypeSelected,
          ),
        ],
      ),
    );
  }
}
