import 'package:intl/intl.dart';
import '../constants/app_strings.dart';

class CurrencyUtils {
  CurrencyUtils._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: AppStrings.currencySymbol,
    decimalDigits: 2,
  );

  static final NumberFormat _formatterNoDecimal = NumberFormat.currency(
    locale: 'en_IN',
    symbol: AppStrings.currencySymbol,
    decimalDigits: 0,
  );

  static String format(double amount) => _formatter.format(amount);
  static String formatRounded(double amount) =>
      _formatterNoDecimal.format(amount);

  static String formatCompact(double amount) {
    if (amount >= 100000) {
      return '${AppStrings.currencySymbol}${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${AppStrings.currencySymbol}${(amount / 1000).toStringAsFixed(1)}K';
    }
    return formatRounded(amount);
  }
}
