import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:trvlez_mobile/features/properties/domain/property.dart';
import 'package:trvlez_mobile/features/reservations/presentation/reservations_notifier.dart';

/// Screen for creating a reservation at a property.
///
/// Reached from the property detail "Book Now" button.
class CreateReservationScreen extends StatefulWidget {
  final Property property;
  final ReservationsNotifier notifier;

  const CreateReservationScreen({
    super.key,
    required this.property,
    required this.notifier,
  });

  @override
  State<CreateReservationScreen> createState() =>
      _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _numberOfGuests = 1;
  int _numberOfRooms = 1;
  final _guestNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialRequestsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onStateChanged);
    _guestNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  bool get _isFormValid =>
      _checkInDate != null &&
      _checkOutDate != null &&
      _guestNameController.text.trim().isNotEmpty;

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
          if (_checkOutDate != null &&
              !_checkOutDate!.isAfter(_checkInDate!)) {
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

    final formatter = DateFormat('yyyy-MM-dd');
    final reservation = await widget.notifier.createReservation(
      propertyId: widget.property.id,
      checkInDate: formatter.format(_checkInDate!),
      checkOutDate: formatter.format(_checkOutDate!),
      guestName: _guestNameController.text.trim(),
      guestEmail: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null,
      guestPhone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      numberOfGuests: _numberOfGuests,
      numberOfRooms: _numberOfRooms,
      specialRequests: _specialRequestsController.text.trim().isNotEmpty
          ? _specialRequestsController.text.trim()
          : null,
    );

    if (reservation != null && mounted) {
      context.go('/my-trips');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            if (widget.notifier.createError != null)
              _buildErrorBanner(colorScheme),
            const SizedBox(height: 24),
            _buildSubmitButton(colorScheme),
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
                    child: Icon(Icons.hotel,
                        color: colorScheme.onSurfaceVariant),
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
              child: _DatePickerTile(
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
              child: _DatePickerTile(
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
        Row(
          children: [
            Expanded(
              child: _CounterTile(
                label: 'Guests',
                icon: Icons.person_outline,
                value: _numberOfGuests,
                colorScheme: colorScheme,
                onIncrement: () =>
                    setState(() => _numberOfGuests++),
                onDecrement: _numberOfGuests > 1
                    ? () => setState(() => _numberOfGuests--)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CounterTile(
                label: 'Rooms',
                icon: Icons.bed_outlined,
                value: _numberOfRooms,
                colorScheme: colorScheme,
                onIncrement: () =>
                    setState(() => _numberOfRooms++),
                onDecrement: _numberOfRooms > 1
                    ? () => setState(() => _numberOfRooms--)
                    : null,
              ),
            ),
          ],
        ),
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

  Widget _buildErrorBanner(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.error.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.error.withAlpha(51)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.notifier.createError ?? 'Something went wrong',
              style: GoogleFonts.cabin(
                fontSize: 13,
                color: colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed:
            _isFormValid && !widget.notifier.isCreating
                ? _submitReservation
                : null,
        child: widget.notifier.isCreating
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

// ─── Reusable Widgets ──────────────────────────────────────────────

class _DatePickerTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _DatePickerTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(icon, size: 16, color: colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value,
                    style: GoogleFonts.cabin(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final int value;
  final ColorScheme colorScheme;
  final VoidCallback onIncrement;
  final VoidCallback? onDecrement;

  const _CounterTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.colorScheme,
    required this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCounterButton(
                Icons.remove,
                onDecrement,
                colorScheme,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$value',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              _buildCounterButton(
                Icons.add,
                onIncrement,
                colorScheme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton(
    IconData icon,
    VoidCallback? onTap,
    ColorScheme colorScheme,
  ) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isEnabled
              ? colorScheme.primary.withAlpha(26)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isEnabled
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant.withAlpha(100),
        ),
      ),
    );
  }
}
