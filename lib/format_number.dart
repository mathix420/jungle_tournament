String formatNumber(int number) {
  if (number == null)
    return number.toString();
  if (number >= 1000000) {
    return "${number ~/ 1000000}M";
  } else if (number >= 1000) {
    return "${number ~/ 1000}k";
  }
  return number.toString();
}