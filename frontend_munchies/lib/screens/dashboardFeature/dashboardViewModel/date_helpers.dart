import 'package:frontend_munchies/screens/dashboardFeature/view_opt.dart';

DateTime goForward(ViewOpt selectedView, DateTime chosenDate) {
  if (selectedView == ViewOpt.weekly) {
    return chosenDate.add(const Duration(days: 7));
  } else if (selectedView == ViewOpt.monthly) {
    return DateTime(chosenDate.year, chosenDate.month + 1, 1);
  } else if (selectedView == ViewOpt.annually) {
    return DateTime(chosenDate.year + 1, 1, 1);
  } else {
    return DateTime.now();
  }
}

DateTime goBack(ViewOpt selectedView, DateTime chosenDate) {
  if (selectedView == ViewOpt.weekly) {
    return chosenDate.subtract(const Duration(days: 7));
  } else if (selectedView == ViewOpt.monthly) {
    return DateTime(chosenDate.year, chosenDate.month - 1, 1);
  } else if (selectedView == ViewOpt.annually) {
    return DateTime(chosenDate.year - 1, 1, 1);
  } else {
    return DateTime.now();
  }
}

//should be okay functions
String findStart(ViewOpt selectedView, DateTime chosenDate) {
  DateTime startDate;
  if (selectedView == ViewOpt.weekly) {
    int fromMonday = chosenDate.weekday - 1;
    startDate = DateTime(
      chosenDate.year,
      chosenDate.month,
      chosenDate.day - fromMonday,
    );
  } else if (selectedView == ViewOpt.monthly) {
    startDate = DateTime(chosenDate.year, chosenDate.month, 1);
  } else if (selectedView == ViewOpt.annually) {
    startDate = DateTime(chosenDate.year, 1, 1);
  } else {
    startDate = chosenDate;
  }
  return startDate.toIso8601String().split('T')[0];
}

String findEnd(ViewOpt selectedView, DateTime chosenDate) {
  DateTime endDate;
  if (selectedView == ViewOpt.weekly) {
    int toSunday = 7 - chosenDate.weekday;
    endDate = DateTime(
      chosenDate.year,
      chosenDate.month,
      chosenDate.day + toSunday,
    );
  } else if (selectedView == ViewOpt.monthly) {
    endDate = DateTime(chosenDate.year, chosenDate.month + 1, 0);
  } else if (selectedView == ViewOpt.annually) {
    endDate = DateTime(chosenDate.year, 12, 31);
  } else {
    endDate = chosenDate;
  }
  return endDate.toIso8601String().split('T')[0];
}

String displayRange(ViewOpt selectedView, DateTime chosenDate) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  if (selectedView == ViewOpt.weekly) {
    String startDate = findStart(selectedView, chosenDate);
    String endDate = findEnd(selectedView, chosenDate);
    return "$startDate to $endDate";
    //return findStart(selectedView, chosenDate) + " to " + findEnd(selectedView, chosenDate);
  } else if (selectedView == ViewOpt.monthly) {
    String month = months[chosenDate.month - 1];
    String year = chosenDate.year.toString();
    return "$month $year";
    //return months[chosenDate.month - 1] + " " + chosenDate.year.toString();
  } else if (selectedView == ViewOpt.annually) {
    return chosenDate.year.toString();
  } else {
    return "Future 6 Months";
  }
}
