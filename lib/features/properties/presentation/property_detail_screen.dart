import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:trvlez_mobile/app/routes.dart';
import 'package:trvlez_mobile/core/utils/price_formatter.dart';
import 'package:trvlez_mobile/features/properties/data/properties_repository.dart';
import 'package:trvlez_mobile/features/properties/domain/property.dart';

class PropertyDetailScreen extends StatefulWidget {
  final String propertyId;
  final Property? property;
  final PropertiesRepository repository;

  PropertyDetailScreen({
    super.key,
    String? propertyId,
    this.property,
    required this.repository,
  }) : propertyId = propertyId ?? property?.id ?? '';

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  late Future<Property> _propertyFuture;
  final ScrollController _scrollController = ScrollController();
  bool _isFavorite = false;
  String? _selectedRoomTypeId;

  @override
  void initState() {
    super.initState();
    _loadProperty();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadProperty() {
    _propertyFuture = widget.repository.getPropertyDetail(widget.propertyId);
  }

  void _retry() {
    setState(() {
      _loadProperty();
    });
  }

  void _onRoomTypeSelected(String roomTypeId) {
    setState(() {
      _selectedRoomTypeId =
          (_selectedRoomTypeId == roomTypeId) ? null : roomTypeId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FutureBuilder<Property>(
        future: _propertyFuture,
        builder: (context, snapshot) {
          final displayProperty = snapshot.data ?? widget.property;

          // If there is no property data yet and we are loading
          if (displayProperty == null &&
              snapshot.connectionState == ConnectionState.waiting) {
            return const _PropertyDetailLoadingView();
          }

          // If there is no property data and an error occurred
          if (displayProperty == null && snapshot.hasError) {
            return _PropertyDetailErrorView(
              errorMessage: snapshot.error.toString(),
              onRetry: _retry,
            );
          }

          if (displayProperty == null) {
            return _PropertyDetailErrorView(
              errorMessage: 'Property not found.',
              onRetry: _retry,
            );
          }

          return Stack(
            children: [
              _PropertyHeaderImage(property: displayProperty),
              _PropertyTopBar(
                isFavorite: _isFavorite,
                onFavoriteToggle: () {
                  setState(() => _isFavorite = !_isFavorite);
                },
              ),
              _PropertyContentSheet(
                property: displayProperty,
                isEnriching:
                    snapshot.connectionState == ConnectionState.waiting,
                scrollController: _scrollController,
                selectedRoomTypeId: _selectedRoomTypeId,
                onRoomTypeSelected: _onRoomTypeSelected,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PropertyHeaderImage extends StatelessWidget {
  final Property property;

  const _PropertyHeaderImage({required this.property});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: screenHeight * 0.42,
      child: Stack(
        fit: StackFit.expand,
        children: [
          property.heroImageUrl.isNotEmpty
              ? Image.network(
                  property.heroImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildFallback(colorScheme),
                )
              : _buildFallback(colorScheme),
          // Subtle top gradient for back button contrast
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.scrim.withAlpha(120),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallback(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.hotel_outlined,
          size: 64,
          color: colorScheme.onSurfaceVariant.withAlpha(120),
        ),
      ),
    );
  }
}

class _PropertyTopBar extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const _PropertyTopBar({
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Positioned(
      top: topPadding + 12,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.surface.withAlpha(220),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withAlpha(30),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          GestureDetector(
            onTap: onFavoriteToggle,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.surface.withAlpha(220),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withAlpha(30),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 20,
                color: isFavorite ? Colors.redAccent : colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyContentSheet extends StatelessWidget {
  final Property property;
  final bool isEnriching;
  final ScrollController scrollController;
  final String? selectedRoomTypeId;
  final ValueChanged<String> onRoomTypeSelected;

  const _PropertyContentSheet({
    required this.property,
    required this.isEnriching,
    required this.scrollController,
    this.selectedRoomTypeId,
    required this.onRoomTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Positioned(
      top: screenHeight * 0.36,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withAlpha(25),
              blurRadius: 16,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PropertyOverviewSection(property: property),
                    const SizedBox(height: 20),
                    _PropertyDescriptionSection(
                      description: property.longDescription.isNotEmpty
                          ? property.longDescription
                          : property.shortDescription,
                    ),
                    if (property.amenities.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _PropertyFacilitiesSection(
                        facilities: property.amenities,
                      ),
                    ],
                    const SizedBox(height: 24),
                    _PropertyRoomTypesSection(
                      property: property,
                      roomTypes: property.roomTypes,
                      isLoading: isEnriching,
                      selectedRoomTypeId: selectedRoomTypeId,
                      onRoomTypeSelected: onRoomTypeSelected,
                      propertyCurrency: property.currencyCode,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // Pinned Bottom Bar
            _PropertyBottomBar(
              property: property,
              isLoading: isEnriching,
              selectedRoomTypeId: selectedRoomTypeId,
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyOverviewSection extends StatelessWidget {
  final Property property;

  const _PropertyOverviewSection({required this.property});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                property.name,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            if (property.propertyType != null &&
                property.propertyType!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  property.propertyType!.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                property.locationString.isNotEmpty
                    ? property.locationString
                    : 'Location details upon booking',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        if (property.checkinTime != null || property.checkoutTime != null) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (property.checkinTime != null)
                _InfoBadge(
                  icon: Icons.login,
                  label: 'Check-in: ${property.checkinTime}',
                ),
              if (property.checkoutTime != null)
                _InfoBadge(
                  icon: Icons.logout,
                  label: 'Check-out: ${property.checkoutTime}',
                ),
              if (property.totalRooms != null && property.totalRooms! > 0)
                _InfoBadge(
                  icon: Icons.meeting_room_outlined,
                  label: '${property.totalRooms} Rooms',
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(150),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyDescriptionSection extends StatefulWidget {
  final String description;

  const _PropertyDescriptionSection({required this.description});

  @override
  State<_PropertyDescriptionSection> createState() =>
      _PropertyDescriptionSectionState();
}

class _PropertyDescriptionSectionState
    extends State<_PropertyDescriptionSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final text = widget.description.isNotEmpty
        ? widget.description
        : 'Experience premier hospitality, comfortable rooms, and dedicated service during your stay.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Property',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          maxLines: _isExpanded ? null : 3,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        if (text.length > 100) ...[
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Text(
              _isExpanded ? 'Show less' : 'Read more',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PropertyFacilitiesSection extends StatelessWidget {
  final List<String> facilities;

  const _PropertyFacilitiesSection({required this.facilities});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Facilities & Amenities',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: facilities
                .map(
                  (f) => _FacilityPill(
                    icon: _getFacilityIcon(f),
                    label: _formatFacilityLabel(f),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  static IconData _getFacilityIcon(String facility) {
    final f = facility.toLowerCase();
    if (f.contains('wifi') || f.contains('internet')) return Icons.wifi;
    if (f.contains('pool') || f.contains('swim')) return Icons.pool;
    if (f.contains('spa') || f.contains('wellness') || f.contains('massage')) {
      return Icons.spa;
    }
    if (f.contains('park')) return Icons.local_parking;
    if (f.contains('restaurant') ||
        f.contains('dining') ||
        f.contains('food') ||
        f.contains('dinner')) {
      return Icons.restaurant;
    }
    if (f.contains('gym') || f.contains('fitness')) {
      return Icons.fitness_center;
    }
    if (f.contains('bar') || f.contains('drink') || f.contains('cocktail')) {
      return Icons.local_bar;
    }
    if (f.contains('ac') || f.contains('air')) return Icons.ac_unit;
    if (f.contains('heat')) return Icons.thermostat;
    if (f.contains('breakfast') || f.contains('coffee')) {
      return Icons.free_breakfast;
    }
    if (f.contains('room service')) return Icons.room_service;
    if (f.contains('beach') || f.contains('ocean') || f.contains('sea')) {
      return Icons.beach_access;
    }
    if (f.contains('mountain') || f.contains('hill') || f.contains('view')) {
      return Icons.landscape;
    }
    if (f.contains('tub') || f.contains('bath') || f.contains('jacuzzi')) {
      return Icons.hot_tub;
    }
    if (f.contains('tv') || f.contains('television')) return Icons.tv;
    if (f.contains('balcony') || f.contains('terrace')) return Icons.balcony;
    return Icons.check_circle_outline;
  }

  static String _formatFacilityLabel(String facility) {
    return facility
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }
}

class _FacilityPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FacilityPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(180),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              color: colorScheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyRoomTypesSection extends StatelessWidget {
  final Property? property;
  final List<RoomType> roomTypes;
  final bool isLoading;
  final String? selectedRoomTypeId;
  final ValueChanged<String>? onRoomTypeSelected;
  final String? propertyCurrency;

  const _PropertyRoomTypesSection({
    this.property,
    required this.roomTypes,
    this.isLoading = false,
    this.selectedRoomTypeId,
    this.onRoomTypeSelected,
    this.propertyCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Available Rooms',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (roomTypes.isEmpty && !isLoading)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(100),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Direct room booking available at check-in.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...roomTypes.map(
            (rt) => _RoomTypeCard(
              roomType: rt,
              isSelected: selectedRoomTypeId == rt.id,
              onTap: onRoomTypeSelected != null
                  ? () => onRoomTypeSelected!(rt.id)
                  : null,
              propertyCurrency: propertyCurrency,
              onBookNow: property != null && rt.hasValidPrice && rt.isActive
                  ? () {
                      context.push(
                        AppRoutes.createReservation,
                        extra: {
                          'property': property!,
                          'selectedRoomTypeId': rt.id,
                        },
                      );
                    }
                  : null,
            ),
          ),
      ],
    );
  }
}

class _RoomTypeCard extends StatelessWidget {
  final RoomType roomType;
  final bool isSelected;
  final VoidCallback? onTap;
  final String? propertyCurrency;
  final VoidCallback? onBookNow;

  const _RoomTypeCard({
    required this.roomType,
    this.isSelected = false,
    this.onTap,
    this.propertyCurrency,
    this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isBookable = roomType.hasValidPrice && roomType.isActive;

    return GestureDetector(
      onTap: isBookable ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withAlpha(20)
              : colorScheme.surfaceContainerHighest.withAlpha(100),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withAlpha(50),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (isSelected) ...[
                        Icon(
                          Icons.check_circle,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          roomType.name,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isBookable
                                ? colorScheme.onSurface
                                : colorScheme.onSurface.withAlpha(150),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 14,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Max ${roomType.maxOccupancy}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (isBookable)
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: PriceFormatter.formatPrice(
                        roomType.pricePerNight!,
                        currencyCode: roomType.currencyCode ?? propertyCurrency,
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                    TextSpan(
                      text: ' / night',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withAlpha(60),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Pricing unavailable',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.error,
                  ),
                ),
              ),
            if (roomType.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                roomType.description,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Adults: ${roomType.maxAdults}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (roomType.maxChildren > 0) ...[
                      const SizedBox(width: 12),
                      Text(
                        'Children: ${roomType.maxChildren}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  !isBookable
                      ? 'Unavailable'
                      : isSelected
                          ? 'Selected'
                          : 'Tap to select',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: !isBookable
                        ? colorScheme.error
                        : isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant.withAlpha(150),
                  ),
                ),
              ],
            ),
            if (isSelected && isBookable && onBookNow != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onBookNow,
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text(
                    'Book This Room',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PropertyBottomBar extends StatelessWidget {
  final Property property;
  final bool isLoading;
  final String? selectedRoomTypeId;

  const _PropertyBottomBar({
    required this.property,
    this.isLoading = false,
    this.selectedRoomTypeId,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final RoomType? selectedRoom = selectedRoomTypeId != null
        ? property.roomTypes
            .where((r) => r.id == selectedRoomTypeId)
            .firstOrNull
        : null;

    final String priceLabel;
    final String priceDisplay;
    final bool canBook;

    if (selectedRoom != null) {
      priceLabel = 'Selected Room';
      if (selectedRoom.hasValidPrice) {
        priceDisplay =
            '${PriceFormatter.formatPrice(selectedRoom.pricePerNight!, currencyCode: selectedRoom.currencyCode ?? property.currencyCode)} / night';
        canBook = !isLoading;
      } else {
        priceDisplay = 'Pricing unavailable';
        canBook = false;
      }
    } else {
      priceLabel = 'Pricing';
      final validRooms = property.roomTypes
          .where((r) => r.isActive && r.hasValidPrice)
          .toList();
      if (validRooms.isNotEmpty) {
        final minPrice = validRooms
            .map((r) => r.pricePerNight!)
            .reduce((a, b) => a < b ? a : b);
        priceDisplay =
            'From ${PriceFormatter.formatPrice(minPrice, currencyCode: property.currencyCode)} / night';
        canBook = !isLoading;
      } else if (property.pricePerNight != null && property.pricePerNight! > 0) {
        priceDisplay =
            '${PriceFormatter.formatPrice(property.pricePerNight!, currencyCode: property.currencyCode)} / night';
        canBook = !isLoading;
      } else {
        priceDisplay = 'Pricing unavailable';
        canBook = false;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    priceLabel,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    priceDisplay,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: canBook ? colorScheme.primary : colorScheme.error,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: canBook
                  ? () {
                      context.push(
                        AppRoutes.createReservation,
                        extra: {
                          'property': property,
                          'selectedRoomTypeId': selectedRoomTypeId,
                        },
                      );
                    }
                  : null,
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward, size: 18),
              label: Text(
                isLoading ? 'Loading...' : 'Book Now',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyDetailLoadingView extends StatelessWidget {
  const _PropertyDetailLoadingView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Loading property details...',
            style: GoogleFonts.inter(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyDetailErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _PropertyDetailErrorView({
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Unable to load property',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
