import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trvlez_mobile/features/profile/presentation/profile_notifier.dart';
import 'package:trvlez_mobile/features/properties/data/properties_repository.dart';
import 'package:trvlez_mobile/features/properties/domain/property.dart';
import 'package:trvlez_mobile/features/reservations/presentation/reservations_notifier.dart';
import 'package:trvlez_mobile/features/reservations/presentation/widgets/counter_tile.dart';
import 'package:trvlez_mobile/features/reservations/presentation/widgets/date_picker_tile.dart';
import 'package:trvlez_mobile/app/routes.dart';

/// Screen for creating a reservation at a property.
///
/// Reached from the property detail "Book Now" button or via direct property booking link.
class CreateReservationScreen extends ConsumerStatefulWidget {
  final Property? property;
  final String? propertyId;
  final String? initialRoomTypeId;

  const CreateReservationScreen({
    super.key,
    this.property,
    this.propertyId,
    this.initialRoomTypeId,
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

    // Auto-prefill traveler phone from profile if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final profile = ref.read(currentProfileProvider).valueOrNull;
      if (profile?.phone != null &&
          profile!.phone!.isNotEmpty &&
          _phoneController.text.isEmpty) {
        _phoneController.text = profile.phone!;
      }
    });
  }

  void _loadProperty() {
    final propId = widget.property?.id ?? widget.propertyId ?? '';
    if (propId.isNotEmpty) {
      setState(() {
        _propertyFuture =
            ref.read(propertiesRepositoryProvider).getPropertyDetail(propId);
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
      _selectedRoomCounts[prop.roomTypes.first.id] = 1;
    }
  }

  int get _totalSelectedRooms {
    return _selectedRoomCounts.values.fold(0, (sum, count) => sum + count);
  }

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

  @override
  void dispose() {
    _guestNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _checkInDate != null &&
      _checkOutDate != null &&
      _guestNameController.text.trim().isNotEmpty &&
      _totalSelectedRooms > 0 &&
      !_isOccupancyExceeded;

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
      builder: (context, child) {
        final colorScheme = Theme.of(context).colorScheme;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: colorScheme.copyWith(
              primary: colorScheme.primary,
              onPrimary: colorScheme.onPrimary,
              surface: colorScheme.surface,
              onSurface: colorScheme.onSurface,
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: colorScheme.surface,
              headerBackgroundColor: colorScheme.primary,
              headerForegroundColor: colorScheme.onPrimary,
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return colorScheme.primary;
                }
                return null;
              }),
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return colorScheme.onPrimary;
                }
                return colorScheme.onSurface;
              }),
              todayBorder: BorderSide(color: colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          // Reset checkout if it's before or same as new checkin
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

    // Combine selected date with current UTC time
    // so that same-day bookings pass the backend's strict past-time check.
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
      final typeId = entry.key;
      final count = entry.value;
      for (int i = 0; i < count; i++) {
        roomTypeIds.add(typeId);
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
            return Scaffold(
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
                  ),
                ),
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Scaffold(
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
                  ),
                ),
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Unable to load property details',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error?.toString() ?? 'Property not found',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cabin(fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _loadProperty,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final createState = ref.watch(createReservationProvider);
    final isCreating = createState.isLoading;
    final createError = createState.hasError
        ? createState.error.toString()
        : null;

    final property = _activeProperty ?? widget.property;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Book Your Stay',
          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (property != null) _buildPropertyCard(colorScheme, property),
            const SizedBox(height: 24),
            _buildDateSection(colorScheme),
            const SizedBox(height: 24),
            if (property != null)
              _buildGuestRoomSection(colorScheme, property),
            const SizedBox(height: 24),
            _buildGuestInfoSection(colorScheme),
            const SizedBox(height: 24),
            _buildSpecialRequests(colorScheme),
            const SizedBox(height: 16),
            if (createError != null)
              _buildErrorBanner(colorScheme, createError),
            const SizedBox(height: 24),
            _buildSubmitButton(colorScheme, isCreating),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyCard(ColorScheme colorScheme, Property property) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: property.heroImageUrl.isNotEmpty
                ? Image.network(
                    property.heroImageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 64,
                      height: 64,
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.hotel,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : Container(
                    width: 64,
                    height: 64,
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.hotel,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.name,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  property.locationString,
                  style: GoogleFonts.cabin(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(ColorScheme colorScheme) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stay Dates',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DatePickerTile(
                label: 'Check-in',
                value: _checkInDate != null
                    ? dateFormat.format(_checkInDate!)
                    : 'Select date',
                icon: Icons.calendar_today_outlined,
                colorScheme: colorScheme,
                onTap: () => _selectDate(isCheckIn: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DatePickerTile(
                label: 'Check-out',
                value: _checkOutDate != null
                    ? dateFormat.format(_checkOutDate!)
                    : 'Select date',
                icon: Icons.calendar_today_outlined,
                colorScheme: colorScheme,
                onTap: () => _selectDate(isCheckIn: false),
              ),
            ),
          ],
        ),
        if (_checkInDate != null && _checkOutDate != null) ...[
          const SizedBox(height: 8),
          Text(
            '${_checkOutDate!.difference(_checkInDate!).inDays} night(s)',
            style: GoogleFonts.cabin(
              fontSize: 13,
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGuestRoomSection(ColorScheme colorScheme, Property property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Guests & Rooms',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        CounterTile(
          label: 'Guests',
          icon: Icons.person_outline,
          value: _numberOfGuests,
          colorScheme: colorScheme,
          onIncrement: () => setState(() => _numberOfGuests++),
          onDecrement: _numberOfGuests > 1
              ? () => setState(() => _numberOfGuests--)
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          'Room Types',
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        if (property.roomTypes.isEmpty)
          Text(
            'No rooms available for this property.',
            style: GoogleFonts.cabin(fontSize: 14, color: colorScheme.error),
          )
        else
          ...property.roomTypes.map((roomType) {
            final currentSelected = _selectedRoomCounts[roomType.id] ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: CounterTile(
                label: roomType.name,
                icon: Icons.bed_outlined,
                value: currentSelected,
                colorScheme: colorScheme,
                onIncrement: () => setState(
                  () => _selectedRoomCounts[roomType.id] = currentSelected + 1,
                ),
                onDecrement: currentSelected > 0
                    ? () => setState(
                        () => _selectedRoomCounts[roomType.id] =
                            currentSelected - 1,
                      )
                    : null,
              ),
            );
          }),
        if (_isOccupancyExceeded) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withAlpha(80),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.error),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Selected rooms accommodate up to $_totalMaxCapacity guests. Please add more rooms or adjust guest count to confirm reservation.',
                    style: GoogleFonts.cabin(
                      fontSize: 13,
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGuestInfoSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Guest Information',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _guestNameController,
          decoration: const InputDecoration(
            hintText: 'Full name',
            prefixIcon: Icon(Icons.person_outline),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Email (optional)',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: 'Phone (optional)',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialRequests(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Special Requests',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _specialRequestsController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Any special requests? (optional)',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(ColorScheme colorScheme, String errorMsg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.errorContainer),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMsg,
              style: GoogleFonts.cabin(fontSize: 13, color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ColorScheme colorScheme, bool isCreating) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: _isFormValid && !isCreating ? _submitReservation : null,
        child: isCreating
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.onPrimary,
                ),
              )
            : Text(
                'Confirm Reservation',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
