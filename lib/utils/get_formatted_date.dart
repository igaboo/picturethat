import 'package:intl/intl.dart';

String getFormattedDate(DateTime date) {
  final nowLocal = DateTime.now();
  final dateLocal = date.toLocal();

  final startOfTodayLocal = DateTime(
    nowLocal.year,
    nowLocal.month,
    nowLocal.day,
  );
  final startOfDateLocal = DateTime(
    dateLocal.year,
    dateLocal.month,
    dateLocal.day,
  );

  final differenceInCalendarDays =
      startOfTodayLocal.difference(startOfDateLocal).inDays;

  final formattedDatePart =
      "${DateFormat('MMMM d').format(dateLocal)}${_getDaySuffix(dateLocal.day)}";

  if (differenceInCalendarDays == 0) {
    return "Today, $formattedDatePart";
  } else if (differenceInCalendarDays == 1) {
    return "Yesterday, $formattedDatePart";
  } else {
    return formattedDatePart;
  }
}

String _getDaySuffix(int day) {
  if (day >= 11 && day <= 13) {
    return 'th';
  }
  switch (day % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}
