import 'package:intl/intl.dart';

String getTimeLeft() {
  final now = DateTime.now();
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
  final timeLeft = tomorrow.difference(now);

  if (timeLeft.inHours >= 1) {
    final hours = timeLeft.inHours;
    final hourString = Intl.plural(hours, one: "hour", other: "hours");
    return "$hours $hourString left";
  } else {
    final minutes = timeLeft.inMinutes;
    final minuteString = Intl.plural(minutes, one: "minute", other: "minutes");
    return "$minutes $minuteString left";
  }
}
