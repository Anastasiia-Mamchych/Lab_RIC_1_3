import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFmt = NumberFormat('#,##0.00', 'uk_UA');
  static final NumberFormat _percentFmt = NumberFormat('#,##0.00', 'uk_UA');

  static String currency(double value) => '${_currencyFmt.format(value)} ₴';
  static String percent(double value) => '${_percentFmt.format(value)} %';

  static String months(int months) {
    final years = months ~/ 12;
    final rem = months % 12;
    final parts = <String>[];
    if (years > 0) parts.add('$years ${_yearLabel(years)}');
    if (rem > 0) parts.add('$rem ${_monthLabel(rem)}');
    return parts.join(' ');
  }

  static String _yearLabel(int n) {
    final mod = n % 10;
    if (n >= 11 && n <= 14) return 'років';
    if (mod == 1) return 'рік';
    if (mod >= 2 && mod <= 4) return 'роки';
    return 'років';
  }

  static String _monthLabel(int n) {
    final mod = n % 10;
    if (n >= 11 && n <= 14) return 'місяців';
    if (mod == 1) return 'місяць';
    if (mod >= 2 && mod <= 4) return 'місяці';
    return 'місяців';
  }
}
