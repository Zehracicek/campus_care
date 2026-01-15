import 'package:intl/intl.dart';

extension StringCasingExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  String toTitleCase() {
    return split(' ').map((word) => word.capitalizeFirst()).join(' ');
  }

  /// "1234.5".toN2() → "1.234,50"
  /// "1234,5".toN2(locale: 'en_US') → "1,234.50"
  /// Dönüşüm hatalıysa orijinal metni döner.
  String toN2({String locale = 'tr_TR'}) {
    // Virgül–nokta farklılıklarını hesaba katarak sayıyı parse et
    final cleaned = replaceAll(' ', '').replaceAll(',', '.');
    final number = double.tryParse(cleaned);
    if (number == null) return this;

    final formatter = NumberFormat('#,##0.00', locale);
    return formatter.format(number);
  }

  String toTwoLineDate() {
    final parts = split('.');
    if (parts.length == 3) {
      return '${parts[0]}.${parts[1]}\n${parts[2]}';
    }
    return this;
  }

  String toTwoLine() {
    if (split(' ').length == 2) {
      return '${split(' ')[0]}\n${split(' ')[1]}';
    }
    return this;
  }

  String toNormalNumber() {
    return replaceAll(' ', '').replaceAll(',', '.');
  }

  String toFormattedDate({String locale = 'tr_TR'}) {
    try {
      final dateTime = DateTime.parse(this);
      final date = DateFormat('dd.MM.yyyy HH:mm').format(dateTime);

      return date;
    } catch (e) {
      return this;
    }
  }
}
