String formatNumber(double? value) {
  if (value == null) return '0';

  if (value == value.truncateToDouble()) {
    return value.toInt().toString();
  }

  return value.toString();
}
