String getFormattedNumber(int number) {
  if (number < 1000) {
    return number.toString();
  } else if (number < 1000000) {
    return "${(number / 1000).toStringAsFixed(1)}k";
  } else {
    return "${(number / 1000000).toStringAsFixed(1)}m";
  }
}
