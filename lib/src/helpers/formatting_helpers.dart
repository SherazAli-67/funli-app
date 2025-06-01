import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

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

  static String getFormattedDOBWithYearsOld(DateTime dob){
    String formattedDOB = '';
    int currentYear = DateTime.now().year;
    int dobYear = dob.year;
    int yearsOld = currentYear - dobYear;
    debugPrint("Dob Year: ${dobYear}");
    DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    formattedDOB = '${dateFormat.format(dob)} - $yearsOld years old';
    return formattedDOB;
  }
}