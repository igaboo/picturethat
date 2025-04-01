String getTimeLeft() {
  final now = DateTime.now();
  final tomorrowMidnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);
  final timeLeft = tomorrowMidnight.difference(now);
  final totalHours = timeLeft.inHours;
  final remainingMinutes = timeLeft.inMinutes % 60;

  if (totalHours >= 1) {
    if (remainingMinutes > 0) {
      return "${totalHours}h ${remainingMinutes}m left";
    } else {
      return "${totalHours}h left";
    }
  } else {
    final totalMinutesLeft = timeLeft.inMinutes;

    if (totalMinutesLeft == 0 && timeLeft.inSeconds > 0) {
      return "1m left";
    }

    return "${totalMinutesLeft}m left";
  }
}
