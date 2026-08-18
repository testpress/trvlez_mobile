import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trvlez_mobile/features/properties/domain/property.dart';
import 'package:trvlez_mobile/features/reservations/presentation/reservations_notifier.dart';
import 'package:trvlez_mobile/features/reservations/presentation/widgets/counter_tile.dart';
import 'package:trvlez_mobile/features/reservations/presentation/widgets/date_picker_tile.dart';
import 'package:trvlez_mobile/app/routes.dart';

/// Screen for creating a reservation at a property.
///
/// Reached from the property detail "Book Now" button.
class CreateReservationScreen extends ConsumerStatefulWidget {
  final Property property;

  const CreateReservationScreen({super.key, required this.property});

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

  @override
  void initState() {
    super.initState();

    // Initialize selected counts
    for (final rt in widget.property.roomTypes) {
      _selectedRoomCounts.putIfAbsent(rt.id, () => 0);
    }

    // Select 1 room of the first type by default if available
    if (widget.property.roomTypes.isNotEmpty) {
      _selectedRoomCounts[widget.property.roomTypes.first.id] = 1;
    }
  }

  int get _totalSelectedRooms {
    return _selectedRoomCounts.values.fold(0, (sum, count) => sum + count);
  }

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
      _totalSelectedRooms > 0;

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
    if (!_isFormValid) return;

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
          propertyId: widget.property.id,
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
      context.go(AppRoutes.myTrips);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final createState = ref.watch(createReservationProvider);
    final isCreating = createState.isLoading;
    final createError = createState.hasError
        ? createState.error.toString()
        : null;

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
            _buildPropertyCard(colorScheme),
            const SizedBox(height: 24),
            _buildDateSection(colorScheme),
            const SizedBox(height: 24),
            _buildGuestRoomSection(colorScheme),
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

  Widget _buildPropertyCard(ColorScheme colorScheme) {
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
            child: widget.property.heroImageUrl.isNotEmpty
                ? Image.network(
                    widget.property.heroImageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
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
                  widget.property.name,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.property.locationString,
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

  Widget _buildGuestRoomSection(ColorScheme colorScheme) {
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
        if (widget.property.roomTypes.isEmpty)
          Text(
            'No rooms available for this property.',
            style: GoogleFonts.cabin(fontSize: 14, color: colorScheme.error),
          )
        else
          ...widget.property.roomTypes.map((roomType) {
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
