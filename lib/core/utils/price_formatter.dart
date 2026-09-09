import 'package:intl/intl.dart';

/// Formats currency codes and price amounts into user-friendly strings.
class PriceFormatter {
  const PriceFormatter._();

  /// Returns the standard currency symbol for [currencyCode], falling back to '$' or the code itself.
  static String getCurrencySymbol(String? currencyCode) {
    if (currencyCode == null || currencyCode.isEmpty) return '\$';
    try {
      final symbol = NumberFormat.simpleCurrency(name: currencyCode).currencySymbol;
      return symbol.isNotEmpty ? symbol : currencyCode;
    } catch (_) {
      return currencyCode;
    }
  }

  /// Formats a nightly room rate or single item price (e.g. '$150', '€120.50').
  static String formatPrice(double price, {String? currencyCode}) {
    final symbol = getCurrencySymbol(currencyCode);
    final isWhole = price % 1 == 0;
    final formattedAmount = isWhole ? price.toInt().toString() : price.toStringAsFixed(2);
    return '$symbol$formattedAmount';
  }

  /// Formats a total reservation or invoice amount with optional currency suffix (e.g. '$300 USD').
  static String formatTotal(double amount, {String? currencyCode}) {
    final symbol = getCurrencySymbol(currencyCode);
    final isWhole = amount % 1 == 0;
    final formattedAmount = isWhole ? amount.toInt().toString() : amount.toStringAsFixed(2);
    final codeSuffix = (currencyCode != null && currencyCode.isNotEmpty) ? ' $currencyCode' : '';
    return '$symbol$formattedAmount$codeSuffix';
  }

  /// Safely parses a numeric value or numeric [String] into a [double].
  ///
  /// Handles backend responses where Decimal or Numeric fields may be serialized
  /// as either raw numbers or JSON strings (e.g. "2000.0", "150.00", 2000.0).
  static double? parsePrice(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
