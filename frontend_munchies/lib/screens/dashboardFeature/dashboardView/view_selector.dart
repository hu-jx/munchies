import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/screens/dashboardFeature/view_opt.dart';

String getLabel(ViewOpt view) {
  switch (view) {
    case ViewOpt.weekly:
      return "Weekly";
    case ViewOpt.monthly:
      return "Monthly";
    case ViewOpt.annually:
      return "Yearly";
    case ViewOpt.futureView:
      return "Future";
  }
}

List<PopupMenuEntry<ViewOpt>> popUpButtonOptions(ViewOpt selectedView) {
return [
        const PopupMenuItem<ViewOpt>(
          value: ViewOpt.weekly,
          child: Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Text(
              'Weekly',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colours.lightBeige,
              ),
            ),
          ),
        ),
        const PopupMenuItem<ViewOpt>(
          value: ViewOpt.monthly,
          child: Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Text(
              'Monthly',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colours.lightBeige,
              ),
            ),
          ),
        ),
        const PopupMenuItem<ViewOpt>(
          value: ViewOpt.annually,
          child: Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Text(
              'Yearly',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colours.lightBeige,
              ),
            ),
          ),
        ),
        const PopupMenuItem<ViewOpt>(
          value: ViewOpt.futureView,
          child: Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Text(
              'Future You',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colours.lightBeige,
              ),
            ),
          ),
        ),
      ];
}
