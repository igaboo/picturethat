import 'package:intl/intl.dart';

String getFormattedDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date).inDays;

  if (difference == 0) {
    return "Today, ${DateFormat('MMMM d').format(date)}${_getDaySuffix(date.day)}";
  } else if (difference == 1) {
    return "Yesterday, ${DateFormat('MMMM d').format(date)}${_getDaySuffix(date.day)}";
  } else {
    return "${DateFormat('MMMM d').format(date)}${_getDaySuffix(date.day)}";
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
