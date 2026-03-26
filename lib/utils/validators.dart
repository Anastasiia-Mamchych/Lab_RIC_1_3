class Validators {
  static String? amount(String? value, {String label = 'Сума'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label є обов\'язковим полем';
    }
    final normalized = value.trim().replaceAll(',', '.');
    final num = double.tryParse(normalized);
    if (num == null) return '$label має бути числом';
    if (num <= 0) return '$label має бути більше нуля';
    if (num > 999999999) return '$label не може перевищувати 999 999 999';
    return null;
  }

  static String? rate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ставка є обов\'язковим полем';
    }
    final normalized = value.trim().replaceAll(',', '.');
    final num = double.tryParse(normalized);
    if (num == null) return 'Ставка має бути числом';
    if (num <= 0) return 'Ставка має бути більше 0 %';
    if (num > 1000) return 'Ставка не може перевищувати 1000 %';
    return null;
  }

  static String? term(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Термін є обов\'язковим полем';
    }
    final num = int.tryParse(value.trim());
    if (num == null) return 'Термін має бути цілим числом';
    if (num < 1) return 'Термін має бути мінімум 1 місяць';
    if (num > 600) return 'Термін не може перевищувати 600 місяців';
    return null;
  }

  static String? contribution(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final normalized = value.trim().replaceAll(',', '.');
    final num = double.tryParse(normalized);
    if (num == null) return 'Значення має бути числом';
    if (num < 0) return 'Значення не може бути від\'ємним';
    return null;
  }

  static double parseDouble(String value) =>
      double.parse(value.trim().replaceAll(',', '.'));
}
