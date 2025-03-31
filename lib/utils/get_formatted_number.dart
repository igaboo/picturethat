import 'package:intl/intl.dart';

String getFormattedUnit({
  required int number,
  required String unit,
}) {
  final locale = Intl.getCurrentLocale();

  final compactNumberFormat = NumberFormat.compact(locale: locale);
  compactNumberFormat.maximumFractionDigits = 1;
  final String formattedCount = compactNumberFormat.format(number);

  final String pluralizedUnit = Intl.plural(
    number,
    one: unit,
    other: "${unit}s",
    locale: locale,
  );

  return "$formattedCount $pluralizedUnit";
}
