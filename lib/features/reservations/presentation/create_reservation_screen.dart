import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_radius.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_spacing.dart';
import 'package:trvlez_mobile/core/widgets/app_button.dart';
import 'package:trvlez_mobile/core/widgets/error_view.dart';
import 'package:trvlez_mobile/core/widgets/loading_view.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';
import 'package:trvlez_mobile/features/reservations/presentation/providers/reservations_providers.dart';
import 'package:trvlez_mobile/features/reservations/presentation/widgets/date_picker_tile.dart';
import 'package:trvlez_mobile/features/reservations/presentation/widgets/guest_selection_section.dart';
import 'package:trvlez_mobile/features/reservations/presentation/widgets/price_breakdown_section.dart';
import 'package:trvlez_mobile/features/reservations/presentation/widgets/room_selection_section.dart';

/// Screen for creating a reservation at a property.
class CreateReservationScreen extends ConsumerStatefulWidget {
  final Property? property;
  final String? propertyId;
  final String? initialRoomTypeId;
  final Future<Property> Function(String propertyId)? propertyLoader;
  final String? initialPhone;

  const CreateReservationScreen({
    super.key,
    this.property,
    this.propertyId,
    this.initialRoomTypeId,
    this.propertyLoader,
    this.initialPhone,
  });

  @override
  ConsumerState<CreateReservationScreen> createState() =>
      _CreateReservationScreenState();
}

class _CreateReservationScreenState
    extends ConsumerState<CreateReservationScreen> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _numberOfGuests = 1;
  final Map<String, int> _selectedRoomCounts = {};
  final _guestNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialRequestsController = TextEditingController();

  Property? _activeProperty;
  Future<Property>? _propertyFuture;

  @override
  void initState() {
    super.initState();

    if (widget.property != null && widget.property!.roomTypes.isNotEmpty) {
      _activeProperty = widget.property;
      _initRoomCounts(widget.property!);
    } else {
      _loadProperty();
    }

    // Auto-prefill traveler phone if provided
    if (widget.initialPhone != null &&
        widget.initialPhone!.isNotEmpty &&
        _phoneController.text.isEmpty) {
      _phoneController.text = widget.initialPhone!;
    }
  }

  void _loadProperty() {
    final propId = widget.property?.id ?? widget.propertyId ?? '';
    if (propId.isNotEmpty && widget.propertyLoader != null) {
      setState(() {
        _propertyFuture = widget.propertyLoader!(propId);
      });
    }
  }

  void _initRoomCounts(Property prop) {
    for (final rt in prop.roomTypes) {
      _selectedRoomCounts.putIfAbsent(rt.id, () => 0);
    }

    if (widget.initialRoomTypeId != null &&
        _selectedRoomCounts.containsKey(widget.initialRoomTypeId)) {
      _selectedRoomCounts[widget.initialRoomTypeId!] = 1;
    } else if (prop.roomTypes.isNotEmpty && _totalSelectedRooms == 0) {
      final firstPricedRoom = prop.roomTypes
          .where((r) => r.hasValidPrice && r.isActive)
          .firstOrNull;
      if (firstPricedRoom != null) {
        _selectedRoomCounts[firstPricedRoom.id] = 1;
      } else {
        _selectedRoomCounts[prop.roomTypes.first.id] = 1;
      }
    }
  }

  int get _numberOfNights {
    if (_checkInDate == null || _checkOutDate == null) return 1;
    final diff = _checkOutDate!.difference(_checkInDate!).inDays;
    return diff > 0 ? diff : 1;
  }

  double get _totalEstimatedAmount {
    if (_activeProperty == null) return 0.0;
    double total = 0.0;
    for (final entry in _selectedRoomCounts.entries) {
      if (entry.value <= 0) continue;
      final rt = _activeProperty!.roomTypes
          .where((r) => r.id == entry.key)
          .firstOrNull;
      if (rt != null && rt.hasValidPrice) {
        total += rt.pricePerNight! * _numberOfNights * entry.value;
      }
    }
    return total;
  }

  bool get _hasInvalidPricingSelected {
    if (_activeProperty == null || _totalSelectedRooms == 0) return false;
    for (final entry in _selectedRoomCounts.entries) {
      if (entry.value <= 0) continue;
      final rt = _activeProperty!.roomTypes
          .where((r) => r.id == entry.key)
          .firstOrNull;
      if (rt == null || !rt.hasValidPrice) return true;
    }
    return false;
  }

  int get _totalSelectedRooms =>
      _selectedRoomCounts.values.fold(0, (sum, count) => sum + count);

  int get _totalMaxCapacity {
    if (_activeProperty == null) return 0;
    int capacity = 0;
    for (final entry in _selectedRoomCounts.entries) {
      if (entry.value <= 0) continue;
      final rt = _activeProperty!.roomTypes
          .where((r) => r.id == entry.key)
          .firstOrNull;
      if (rt != null) {
        capacity += entry.value * rt.maxOccupancy;
      }
    }
    return capacity;
  }

  bool get _isOccupancyExceeded =>
      _totalSelectedRooms > 0 &&
      _totalMaxCapacity > 0 &&
      _numberOfGuests > _totalMaxCapacity;

  bool get _isFormValid =>
      _checkInDate != null &&
      _checkOutDate != null &&
      _guestNameController.text.trim().isNotEmpty &&
      _totalSelectedRooms > 0 &&
      !_isOccupancyExceeded &&
      !_hasInvalidPricingSelected;

  @override
  void dispose() {
    _guestNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate({required bool isCheckIn}) async {
    final now = DateTime.now();
    final firstDate = isCheckIn
        ? now
        : (_checkInDate ?? now).add(const Duration(days: 1));

    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn
          ? (_checkInDate ?? now.add(const Duration(days: 1)))
          : (_checkOutDate ??
                (_checkInDate ?? now).add(const Duration(days: 1))),
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate != null && !_checkOutDate!.isAfter(_checkInDate!)) {
            _checkOutDate = null;
          }
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  Future<void> _submitReservation() async {
    if (!_isFormValid || _activeProperty == null) return;

    final nowUtc = DateTime.now().toUtc();
    final checkInExact = DateTime.utc(
      _checkInDate!.year,
      _checkInDate!.month,
      _checkInDate!.day,
      nowUtc.hour,
      nowUtc.minute,
      nowUtc.second,
    );
    final checkOutExact = DateTime.utc(
      _checkOutDate!.year,
      _checkOutDate!.month,
      _checkOutDate!.day,
      nowUtc.hour,
      nowUtc.minute,
      nowUtc.second,
    );

    final roomTypeIds = <String>[];
    for (final entry in _selectedRoomCounts.entries) {
      for (int i = 0; i < entry.value; i++) {
        roomTypeIds.add(entry.key);
      }
    }

    final reservation = await ref
        .read(createReservationProvider.notifier)
        .createReservation(
          propertyId: _activeProperty!.id,
          checkInDate: checkInExact.toIso8601String(),
          checkOutDate: checkOutExact.toIso8601String(),
          guestName: _guestNameController.text.trim(),
          guestEmail: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
          guestPhone: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
          numberOfGuests: _numberOfGuests,
          roomTypeIds: roomTypeIds,
          specialRequests: _specialRequestsController.text.trim().isNotEmpty
              ? _specialRequestsController.text.trim()
              : null,
        );

    if (reservation != null && mounted) {
      context.pushReplacement(
        AppRoutes.bookingConfirmationPath(reservation.id),
        extra: reservation,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_activeProperty == null && _propertyFuture != null) {
      return FutureBuilder<Property>(
        future: _propertyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: LoadingView(message: 'Loading property details...'),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Scaffold(
              body: ErrorView(
                title: 'Unable to load property details',
                message: snapshot.error?.toString() ?? 'Property not found',
                onRetry: _loadProperty,
              ),
            );
          }

          _activeProperty = snapshot.data!;
          _initRoomCounts(_activeProperty!);
          return _buildForm(context);
        },
      );
    }

    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final colors = context.colors;
    final createState = ref.watch(createReservationProvider);
    final isCreating = createState.isLoading;
    final createError = createState.hasError
        ? createState.error.toString()
        : null;
    final property = _activeProperty ?? widget.property;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Book Your Stay',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (property != null) _buildPropertyCard(property),
            const SizedBox(height: AppSpacing.lg),
            _buildDateSection(),
            const SizedBox(height: AppSpacing.lg),
            if (property != null) ...[
              RoomSelectionSection(
                property: property,
                selectedRoomCounts: _selectedRoomCounts,
                onIncrementRoom: (id) {
                  setState(
                    () => _selectedRoomCounts[id] =
                        (_selectedRoomCounts[id] ?? 0) + 1,
                  );
                },
                onDecrementRoom: (id) {
                  setState(
                    () => _selectedRoomCounts[id] =
                        (_selectedRoomCounts[id] ?? 0) - 1,
                  );
                },
                isOccupancyExceeded: _isOccupancyExceeded,
                totalMaxCapacity: _totalMaxCapacity,
              ),
              const SizedBox(height: AppSpacing.lg),
              PriceBreakdownSection(
                property: property,
                selectedRoomCounts: _selectedRoomCounts,
                numberOfNights: _numberOfNights,
                totalEstimatedAmount: _totalEstimatedAmount,
                hasInvalidPricingSelected: _hasInvalidPricingSelected,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            GuestSelectionSection(
              numberOfGuests: _numberOfGuests,
              onIncrementGuests: () => setState(() => _numberOfGuests++),
              onDecrementGuests: _numberOfGuests > 1
                  ? () => setState(() => _numberOfGuests--)
                  : null,
              nameController: _guestNameController,
              emailController: _emailController,
              phoneController: _phoneController,
              specialRequestsController: _specialRequestsController,
            ),
            if (createError != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.feedbackError.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: colors.feedbackError),
                ),
                child: Text(
                  createError,
                  style: GoogleFonts.cabin(
                    fontSize: 13,
                    color: colors.feedbackError,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Confirm Reservation',
              isLoading: isCreating,
              onPressed: _isFormValid && !isCreating
                  ? _submitReservation
                  : null,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyCard(Property property) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: property.heroImageUrl.isNotEmpty
                ? Image.network(
                    property.heroImageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 64,
                      height: 64,
                      color: colors.surfaceSubtle,
                      child: Icon(Icons.hotel, color: colors.textSecondary),
                    ),
                  )
                : Container(
                    width: 64,
                    height: 64,
                    color: colors.surfaceSubtle,
                    child: Icon(Icons.hotel, color: colors.textSecondary),
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.name,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  property.locationString,
                  style: GoogleFonts.cabin(
                    fontSize: 13,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    final colors = context.colors;
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stay Dates',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: DatePickerTile(
                label: 'Check-in',
                value: _checkInDate != null
                    ? dateFormat.format(_checkInDate!)
                    : 'Select date',
                icon: Icons.calendar_today_outlined,
                colorScheme: Theme.of(context).colorScheme,
                onTap: () => _selectDate(isCheckIn: true),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: DatePickerTile(
                label: 'Check-out',
                value: _checkOutDate != null
                    ? dateFormat.format(_checkOutDate!)
                    : 'Select date',
                icon: Icons.calendar_today_outlined,
                colorScheme: Theme.of(context).colorScheme,
                onTap: () => _selectDate(isCheckIn: false),
              ),
            ),
          ],
        ),
        if (_checkInDate != null && _checkOutDate != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${_checkOutDate!.difference(_checkInDate!).inDays} night(s)',
            style: GoogleFonts.cabin(
              fontSize: 13,
              color: colors.actionPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
