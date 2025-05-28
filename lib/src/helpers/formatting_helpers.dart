class FormatingHelpers {
  static String formatNumber(num value) {
    String format(num n, String suffix) {
      String formatted = (n % 1 == 0) ? n.toStringAsFixed(0) : n.toStringAsFixed(1);
      return '$formatted$suffix';
    }

    if (value >= 1000000000) {
      return format(value / 1000000000, 'B');
    } else if (value >= 1000000) {
      return format(value / 1000000, 'M');
    } else if (value >= 1000) {
      return format(value / 1000, 'k');
    } else {
      return value.toString();
    }
  }
}