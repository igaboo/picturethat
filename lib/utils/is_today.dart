bool isToday(DateTime? date) {
  if (date == null) return false;
  final now = DateTime.now();
  final dateLocal = date.toLocal();
  return dateLocal.year == now.year &&
      dateLocal.month == now.month &&
      dateLocal.day == now.day;
}
