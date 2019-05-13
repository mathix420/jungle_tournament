String formatNumber(int number) {
  if (number == null)
    return "0 vote";
  if (number >= 1000000) {
    return "${number ~/ 1000000}M votes";
  } else if (number >= 1000) {
    return "${number ~/ 1000}k votes";
  } else if (number <= 1) {
    return "$number vote";
  }
  return "$number votes";
}